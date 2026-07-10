#!/bin/bash
# Konect Hackathon - Import CSV data into Supabase Postgres
# Usage (from database/ directory):
#   bash import_data.sh
#   OR
#   bash /path/to/database/import_data.sh
#
# Expects:
#   - supabase.yml in same directory
#   - sample/ subdirectory with the 27 CSVs
#   - .env with POSTGRES_PASSWORD set

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Konect Hackathon Data Import ==="
echo "Working dir: $SCRIPT_DIR"
echo ""

if [ ! -d "sample" ]; then
  echo "ERROR: sample/ directory not found in $SCRIPT_DIR"
  exit 1
fi

# Auto-detect compose file (database/supabase.yml OR app/hackathon/docker-compose.yml)
COMPOSE_FILE=""
if [ -f "supabase.yml" ]; then
  COMPOSE_FILE="supabase.yml"
elif [ -f "docker-compose.yml" ]; then
  COMPOSE_FILE="docker-compose.yml"
else
  echo "ERROR: neither supabase.yml nor docker-compose.yml found in $SCRIPT_DIR"
  exit 1
fi
echo "Compose file: $COMPOSE_FILE"

# Load password from .env for db exec operations
if [ -f ".env" ]; then
  set -a; . ./.env; set +a
fi

# INTEGER columns in the schema reject scientific notation (e.g. '1e+07' for jumlah_sdm_terlibat)
echo "--- Step 1: Pre-process CSVs (convert scientific notation, masked dates, defaults) ---"
python3 - <<'PYEOF'
import os, re

NOT_NULL_DEFAULTS = {
    "barang_keluar_produk.csv": {6: "Sales"},
    "barang_masuk_produk.csv": {12: "Approved"},
    "transaksi_penjualan.csv": {5: "Pending"},
    "pengurus_koperasi.csv": {4: "PENGURUS"},
    "anggota_koperasi.csv": {6: "Requested"},
    "simpanan_anggota.csv": {5: "UNPAID"},
    "profil_koperasi.csv": {2: "Drafted"},
    "aset_koperasi.csv": {4: "Belum Terverifikasi"},
    "gerai_koperasi.csv": {3: "Belum Aktif"},
    "pengajuan_domain.csv": {3: "Not Verified", 4: "Waiting"},
    "pengajuan_kemitraan.csv": {6: "Requested"},
    "pengajuan_pembiayaan.csv": {5: "Requested"},
    "pengajuan_rekening_bank.csv": {5: "Requested"},
    "rat_koperasi.csv": {2: "KDKMP", 9: "Drafted"},
}

COPY_FROM = {
    "aset_koperasi.csv": {17: 16},
}

# Truncate values to fit column length limits defined in the schema
TRUNCATE_LEN = {
    "rat_koperasi.csv": {2: 20},
}

def convert_value(value):
    if not value:
        return value
    if re.match(r"^-?\d+\.?\d*[eE][+-]?\d+$", value):
        try:
            f = float(value)
            if f == int(f) and abs(f) < 10**18:
                return str(int(f))
            return repr(f)
        except (ValueError, OverflowError):
            return value
    if re.match(r"^\d{4}-\*\*-\*\*( \d{2}:\d{2}:\d{2})?$", value):
        return ""
    if re.match(r"^\d{2}-\*\*-\*\*$", value):
        return ""
    if re.match(r"^0000-00-00( \d{2}:\d{2}:\d{2})?$", value):
        return ""
    return value

def normalize(value):
    if value is None:
        return ""
    return value.rstrip("\r\n")

for fname in sorted(os.listdir("sample")):
    if not fname.endswith(".csv"):
        continue
    path = os.path.join("sample", fname)
    defaults = NOT_NULL_DEFAULTS.get(fname, {})
    copy_from = COPY_FROM.get(fname, {})
    trunc_len = TRUNCATE_LEN.get(fname, {})
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    has_coords = False
    coord_idx = -1
    new_lines = []
    
    for line_idx, line in enumerate(lines):
        fields, cur, in_quote = [], "", False
        for ch in line:
            if ch == '"':
                in_quote = not in_quote
                cur += ch
            elif ch == "," and not in_quote:
                fields.append(cur)
                cur = ""
            else:
                cur += ch
        if cur:
            fields.append(cur)
        raw_fields = [normalize(convert_value(f)) for f in fields]
        
        # Determine if file has koordinat_dibulatkan and its index from header
        if line_idx == 0:
            if "koordinat_dibulatkan" in raw_fields:
                has_coords = True
                coord_idx = raw_fields.index("koordinat_dibulatkan")
                
        new_fields = []
        for idx, v in enumerate(raw_fields):
            if (not v) and idx in defaults:
                v = defaults[idx]
            if (not v) and idx in copy_from:
                src = copy_from[idx]
                if src < len(raw_fields) and raw_fields[src]:
                    v = raw_fields[src]
            if v and idx in trunc_len:
                v = v[:trunc_len[idx]]
            new_fields.append(v)
            
        if has_coords and coord_idx != -1:
            val = new_fields[coord_idx].strip('"')
            if line_idx == 0:
                # Replace with latitude, longitude headers
                new_fields[coord_idx:coord_idx+1] = ["latitude", "longitude"]
            else:
                lat, lng = "", ""
                if val and "," in val:
                    parts = val.split(",")
                    if len(parts) == 2:
                        lat = parts[0].strip()
                        lng = parts[1].strip()
                new_fields[coord_idx:coord_idx+1] = [lat, lng]
                
        new_lines.append(",".join(new_fields) + "\n")
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)
    print(f"  preprocessed: {fname}")
PYEOF
echo ""

echo "--- Step 2: Copy preprocessed CSVs into db container ---"
docker compose -f "$COMPOSE_FILE" cp sample/. db:/tmp/sample/
echo "  Files copied"
echo ""

echo "--- Step 3: Truncate tables (in FK-safe order) ---"
TRUNCATE_SQL=$(cat <<'EOF'
TRUNCATE TABLE
  barang_keluar_produk,
  simpanan_anggota,
  barang_masuk_produk,
  inventaris_produk,
  kbli_koperasi,
  pengajuan_rekening_bank,
  pengajuan_pembiayaan,
  pengajuan_kemitraan,
  pengajuan_domain,
  dokumen_koperasi,
  gerai_koperasi,
  modal_koperasi,
  akun_bank_koperasi,
  karyawan_koperasi,
  produk_koperasi,
  transaksi_penjualan,
  anggota_koperasi,
  pengurus_koperasi,
  referensi_koperasi_wilayah,
  profil_koperasi,
  referensi_gerai_koperasi,
  referensi_dokumen_koperasi,
  referensi_komoditas_desa,
  referensi_profil_desa,
  referensi_wilayah,
  rat_koperasi,
  aset_koperasi
RESTART IDENTITY CASCADE;
EOF
)
docker compose -f "$COMPOSE_FILE" exec -T db psql -U postgres -c "$TRUNCATE_SQL" 2>&1
echo ""

import_table() {
  local table="$1"
  local file="$2"
  local columns="$3"

  if [ -n "$columns" ]; then
    docker compose -f "$COMPOSE_FILE" exec -T db psql -U postgres -c "\COPY $table ($columns) FROM '/tmp/sample/$file' DELIMITER ',' CSV HEADER" 2>&1
  else
    docker compose -f "$COMPOSE_FILE" exec -T db psql -U postgres -c "\COPY $table FROM '/tmp/sample/$file' DELIMITER ',' CSV HEADER" 2>&1
  fi
}

echo "--- Step 4: Import data in FK-dependency order ---"

# Level 0: Reference tables
echo ""
echo "[1] referensi_wilayah"
import_table "referensi_wilayah" "referensi_wilayah.csv" \
  "provinsi, kab_kota, kecamatan, desa_kelurahan, kode_wilayah, dibuat_pada, diperbarui_pada"

echo ""
echo "[2] referensi_dokumen_koperasi"
import_table "referensi_dokumen_koperasi" "referensi_dokumen_koperasi.csv" \
  "jenis_dokumen_ref, nama_dokumen, dibuat_pada, diperbarui_pada"

echo ""
echo "[3] referensi_gerai_koperasi"
import_table "referensi_gerai_koperasi" "referensi_gerai_koperasi.csv" \
  "jenis_gerai_ref, nama_jenis_gerai, dibuat_pada, diperbarui_pada"

echo ""
echo "[4] referensi_profil_desa"
import_table "referensi_profil_desa" "referensi_profil_desa.csv" \
  "kode_wilayah, tahun_populasi, total_penduduk, penduduk_laki_laki, penduduk_perempuan, tahun_pendanaan, anggaran_dana_desa, dibuat_pada, diperbarui_pada"

echo ""
echo "[5] referensi_komoditas_desa"
import_table "referensi_komoditas_desa" "referensi_komoditas_desa.csv" \
  "komoditas_ref, kode_wilayah, nama_komoditas, luas_area, volume, jumlah_sdm_terlibat, nilai_potensi_desa, dibuat_pada, diperbarui_pada"

echo ""
echo "[6] profil_koperasi"
import_table "profil_koperasi" "profil_koperasi.csv" \
  "koperasi_ref, nama_koperasi, status_registrasi, bentuk_koperasi, kategori_usaha, nik_koperasi, alamat_lengkap, kode_pos, latitude, longitude, modal_awal, sumber_persetujuan, tentang_koperasi, pola_pengelolaan, metode_pengisian, dibuat_pada, diperbarui_pada"

echo ""
echo "[7] referensi_koperasi_wilayah"
import_table "referensi_koperasi_wilayah" "referensi_koperasi_wilayah.csv" \
  "koperasi_ref, kode_wilayah, dibuat_pada, diperbarui_pada"

echo ""
echo "[8] pengurus_koperasi"
import_table "pengurus_koperasi" "pengurus_koperasi.csv" \
  "pengurus_ref, koperasi_ref, nama, jabatan, status, no_hp, nik, jenis_kelamin, foto_profil, email, alamat, kode_pos, tanggal_lahir, status_pendidikan, periode_mulai, periode_selesai, file_ktp, sumber_data, dibuat_pada, diperbarui_pada"

echo ""
echo "[9] anggota_koperasi (CSV has different column order)"
import_table "anggota_koperasi" "anggota_koperasi.csv" \
  "anggota_ref, koperasi_ref, nama, nik, kode_wilayah, jenis_kelamin, status_keanggotaan, tanggal_terdaftar, dibuat_pada, diperbarui_pada, file_ktp, status_akun, pekerjaan"

echo ""
echo "[10] produk_koperasi"
import_table "produk_koperasi" "produk_koperasi.csv" \
  "produk_sample_id, koperasi_ref, kode_barcode, nama_produk, unit, dibuat_pada, diperbarui_pada"

echo ""
echo "[11] inventaris_produk (CSV has different column order)"
import_table "inventaris_produk" "inventaris_produk.csv" \
  "inventaris_ref, produk_sample_id, koperasi_ref, nama_produk, stok, dibuat_pada, diperbarui_pada, kode_barcode"

echo ""
echo "[12] barang_masuk_produk"
import_table "barang_masuk_produk" "barang_masuk_produk.csv" \
  "barang_masuk_ref, produk_sample_id, koperasi_ref, kode_barcode, nama_produk, nama_tampilan, jumlah_masuk, jumlah_tersedia, harga_beli, harga_jual, total_biaya, keterangan, status, tanggal_masuk, dibuat_pada, diperbarui_pada"

echo ""
echo "[13] transaksi_penjualan"
import_table "transaksi_penjualan" "transaksi_penjualan.csv" \
  "transaksi_sample_id, koperasi_ref, nama_pelanggan, tanggal_dibuat, total_pembayaran, status_transaksi, metode_pembayaran, dibuat_pada, diperbarui_pada"

echo ""
echo "[14] barang_keluar_produk (includes __row_id, status DEFAULT 'Sales')"
import_table "barang_keluar_produk" "barang_keluar_produk.csv" \
  "__row_id, transaksi_sample_id, produk_sample_id, koperasi_ref, kode_barcode, tanggal_keluar, status, nama_produk, nama_tampilan, jumlah_keluar, harga, total_nilai, status_transaksi, dibuat_pada, diperbarui_pada"

echo ""
echo "[15] simpanan_anggota"
import_table "simpanan_anggota" "simpanan_anggota.csv" \
  "simpanan_ref, koperasi_ref, anggota_ref, periode_pembayaran, jumlah_simpanan, status, dibuat_pada, dibayar_pada"

echo ""
echo "[16] kbli_koperasi (includes __row_id)"
import_table "kbli_koperasi" "kbli_koperasi.csv" \
  "__row_id, koperasi_ref, kode_kbli, nama_kbli, tipe_izin_usaha, tahun_kbli, dibuat_pada, diperbarui_pada"

echo ""
echo "[17] akun_bank_koperasi"
import_table "akun_bank_koperasi" "akun_bank_koperasi.csv" \
  "akun_bank_ref, koperasi_ref, nama_rekening, nama_bank, dibuat_pada, diperbarui_pada"

echo ""
echo "[18] aset_koperasi"
import_table "aset_koperasi" "aset_koperasi.csv" \
  "aset_ref, koperasi_ref, nama_aset, tipe_aset, status, progres_pembangunan, foto_utama, foto_sekunder, dokumen_utama, dokumen_sekunder, dokumen_lainnya, luas_lahan, panjang_lahan, lebar_lahan, akses_jalan, latitude, longitude, dibuat_pada, diperbarui_pada"

echo ""
echo "[19] modal_koperasi"
import_table "modal_koperasi" "modal_koperasi.csv" \
  "modal_ref, koperasi_ref, nomor_perjanjian, tipe_sumber, nama_sumber, tipe_modal, jumlah, tanggal_diterima, file_perjanjian, dibuat_pada, diperbarui_pada"

echo ""
echo "[20] karyawan_koperasi"
import_table "karyawan_koperasi" "karyawan_koperasi.csv" \
  "karyawan_ref, koperasi_ref, nama, jabatan, nomor_hp_karyawan, jenis_kelamin, nik, email, status_karyawan, dibuat_pada, diperbarui_pada"

echo ""
echo "[21] gerai_koperasi"
import_table "gerai_koperasi" "gerai_koperasi.csv" \
  "gerai_ref, koperasi_ref, jenis_gerai_ref, status_gerai, foto_gerai, pengisi, akses_internet, akses_listrik, status_kepemilikan_aset_gerai, status_pemanfaatan_aset_gerai, sumber_air_bersih, jenis_bangunan, latitude, longitude, dibuat_pada, diperbarui_pada"

echo ""
echo "[22] dokumen_koperasi"
import_table "dokumen_koperasi" "dokumen_koperasi.csv" \
  "dokumen_ref, koperasi_ref, jenis_dokumen_ref, nomor, tanggal_berlaku, tanggal_kadaluarsa, alamat_pada_dokumen, unggahan_dokumen, dibuat_pada, diperbarui_pada"

echo ""
echo "[23] pengajuan_domain"
import_table "pengajuan_domain" "pengajuan_domain.csv" \
  "domain_ref, koperasi_ref, domain_koperasi, status_verifikasi, status_domain, dibuat_pada, diperbarui_pada"

echo ""
echo "[24] pengajuan_kemitraan"
import_table "pengajuan_kemitraan" "pengajuan_kemitraan.csv" \
  "pengajuan_kemitraan_ref, koperasi_ref, nik, penanggung_jawab, nomor_penanggung_jawab, status_permohonan, bisnis_kemitraan, paket_kemitraan, formulir_permohonan, ktp_penanggung_jawab, tipe_kemitraan, catatan, dibuat_pada, diperbarui_pada"

echo ""
echo "[25] pengajuan_pembiayaan"
import_table "pengajuan_pembiayaan" "pengajuan_pembiayaan.csv" \
  "pengajuan_pembiayaan_ref, koperasi_ref, nik, penanggung_jawab, nomor_penanggung_jawab, status_permohonan, formulir_permohonan_pembiayaan, nominal_permohonan, tenor, tujuan_permohonan, dibuat_pada, diperbarui_pada"

echo ""
echo "[26] pengajuan_rekening_bank"
import_table "pengajuan_rekening_bank" "pengajuan_rekening_bank.csv" \
  "pengajuan_rekening_ref, koperasi_ref, nik, penanggung_jawab, nomor_penanggung_jawab, status, kode_bank, nama_bank, dibuat_pada, diperbarui_pada"

echo ""
echo "[27] rat_koperasi"
import_table "rat_koperasi" "rat_koperasi.csv" \
  "rat_sample_id, koperasi_ref, jenis_sektor_koperasi, urutan_rat, tahun_buku, tahun_rencana_kerja, tahun_rencana_anggaran, tanggal_rat, jumlah_peserta_rat, status_rat, tahap_rat, laporan_posisi_keuangan, laporan_hasil_usaha, rapb_posisi_keuangan, rapb_hasil_usaha, dibuat_pada, diperbarui_pada"

echo ""
echo "--- Step 5: Verify row counts ---"
docker compose -f "$COMPOSE_FILE" exec -T db psql -U postgres -c "
SELECT 'referensi_wilayah' AS tbl, count(*) FROM referensi_wilayah
UNION ALL SELECT 'referensi_profil_desa', count(*) FROM referensi_profil_desa
UNION ALL SELECT 'referensi_komoditas_desa', count(*) FROM referensi_komoditas_desa
UNION ALL SELECT 'referensi_dokumen_koperasi', count(*) FROM referensi_dokumen_koperasi
UNION ALL SELECT 'referensi_gerai_koperasi', count(*) FROM referensi_gerai_koperasi
UNION ALL SELECT 'profil_koperasi', count(*) FROM profil_koperasi
UNION ALL SELECT 'referensi_koperasi_wilayah', count(*) FROM referensi_koperasi_wilayah
UNION ALL SELECT 'pengurus_koperasi', count(*) FROM pengurus_koperasi
UNION ALL SELECT 'anggota_koperasi', count(*) FROM anggota_koperasi
UNION ALL SELECT 'akun_bank_koperasi', count(*) FROM akun_bank_koperasi
UNION ALL SELECT 'aset_koperasi', count(*) FROM aset_koperasi
UNION ALL SELECT 'modal_koperasi', count(*) FROM modal_koperasi
UNION ALL SELECT 'karyawan_koperasi', count(*) FROM karyawan_koperasi
UNION ALL SELECT 'gerai_koperasi', count(*) FROM gerai_koperasi
UNION ALL SELECT 'kbli_koperasi', count(*) FROM kbli_koperasi
UNION ALL SELECT 'dokumen_koperasi', count(*) FROM dokumen_koperasi
UNION ALL SELECT 'produk_koperasi', count(*) FROM produk_koperasi
UNION ALL SELECT 'transaksi_penjualan', count(*) FROM transaksi_penjualan
UNION ALL SELECT 'barang_masuk_produk', count(*) FROM barang_masuk_produk
UNION ALL SELECT 'barang_keluar_produk', count(*) FROM barang_keluar_produk
UNION ALL SELECT 'inventaris_produk', count(*) FROM inventaris_produk
UNION ALL SELECT 'simpanan_anggota', count(*) FROM simpanan_anggota
UNION ALL SELECT 'pengajuan_domain', count(*) FROM pengajuan_domain
UNION ALL SELECT 'pengajuan_kemitraan', count(*) FROM pengajuan_kemitraan
UNION ALL SELECT 'pengajuan_pembiayaan', count(*) FROM pengajuan_pembiayaan
UNION ALL SELECT 'pengajuan_rekening_bank', count(*) FROM pengajuan_rekening_bank
UNION ALL SELECT 'rat_koperasi', count(*) FROM rat_koperasi
ORDER BY tbl;
" 2>&1

echo ""
echo "=== Import complete ==="
