-- ============================================================================
-- Hackathon Cooperative Management Schema
-- Based on original hackathon dummy data (27 CSV files)
-- Domain: Koperasi Desa/Kelurahan Merah Putih
-- ============================================================================
-- Migration: 003_hackathon_schema
-- Description: Creates tables for cooperative management including profiles,
-- members, products, sales, inventory, assets, financing, RAT, etc.
-- ============================================================================

-- ============================================================================
-- ENUMS
-- ============================================================================

CREATE TYPE status_registrasi AS ENUM (
    'Approved', 'Rejected', 'Pending', 'Drafted'
);

CREATE TYPE status_keanggotaan AS ENUM (
    'Approved', 'Requested', 'Rejected', 'Suspended', 'Inactive'
);

CREATE TYPE jenis_kelamin AS ENUM (
    'LAKI-LAKI', 'PEREMPUAN'
);

CREATE TYPE status_simpanan AS ENUM (
    'PAID', 'UNPAID'
);

CREATE TYPE status_transaksi AS ENUM (
    'Paid', 'Unpaid', 'Pending', 'Cancelled'
);

CREATE TYPE status_pengajuan AS ENUM (
    'Requested', 'Verified', 'Approved', 'Rejected', 'Drafted'
);

CREATE TYPE status_domain AS ENUM (
    'Waiting', 'Active', 'Expired', 'Rejected'
);

CREATE TYPE status_aset AS ENUM (
    'Terverifikasi', 'Belum Terverifikasi', 'Drafted'
);

CREATE TYPE status_gerai AS ENUM (
    'Aktif', 'Belum Aktif', 'Nonaktif'
);

CREATE TYPE status_karyawan AS ENUM (
    'Aktif', 'Nonaktif', 'Resign'
);

CREATE TYPE status_pengurus AS ENUM (
    'PENGURUS', 'PENGAWAS'
);

CREATE TYPE status_akun_anggota AS ENUM (
    'Punya Akun', 'Tidak Punya Akun'
);

CREATE TYPE tipe_sumber_modal AS ENUM (
    'BANK', 'MITRA', 'INVESTOR', 'HIBah', 'SWADAYA'
);

CREATE TYPE tipe_modal AS ENUM (
    'PINJAMAN', 'CSR', 'HIBAH', 'PENYERTAAN_MODAL'
);

CREATE TYPE status_barang_masuk AS ENUM (
    'Approved', 'Pending', 'Rejected'
);

CREATE TYPE sektor_koperasi AS ENUM (
    'KDKMP', 'KSP', 'KSU', 'KPRI', 'Lainnya'
);

-- ============================================================================
-- REFERENSI (Lookup / Reference tables)
-- ============================================================================

-- 1. Regional hierarchy (provinces → regencies → districts → villages)
CREATE TABLE referensi_wilayah (
    kode_wilayah   VARCHAR(20)     PRIMARY KEY,
    provinsi       VARCHAR(100)    NOT NULL,
    kab_kota       VARCHAR(100)    NOT NULL,
    kecamatan      VARCHAR(100)    NOT NULL,
    desa_kelurahan VARCHAR(100)    NOT NULL,
    dibuat_pada    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Village profile / demographics (linked to wilayah by kode_wilayah)
CREATE TABLE referensi_profil_desa (
    kode_wilayah         VARCHAR(20)  NOT NULL REFERENCES referensi_wilayah(kode_wilayah),
    tahun_populasi       INTEGER      NOT NULL,
    total_penduduk       INTEGER      NOT NULL DEFAULT 0,
    penduduk_laki_laki   INTEGER      NOT NULL DEFAULT 0,
    penduduk_perempuan   INTEGER      NOT NULL DEFAULT 0,
    tahun_pendanaan      INTEGER,
    anggaran_dana_desa   NUMERIC(18,2) DEFAULT 0,
    dibuat_pada          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (kode_wilayah, tahun_populasi)
);

-- 3. Village commodities
CREATE TABLE referensi_komoditas_desa (
    komoditas_ref       VARCHAR(30)  PRIMARY KEY,
    kode_wilayah        VARCHAR(20)  NOT NULL REFERENCES referensi_wilayah(kode_wilayah),
    nama_komoditas      TEXT         NOT NULL,
    luas_area           VARCHAR(50),
    volume              VARCHAR(50),
    jumlah_sdm_terlibat INTEGER      DEFAULT 0,
    nilai_potensi_desa  NUMERIC(18,2) DEFAULT 0,
    dibuat_pada         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Document type reference (jenis dokumen koperasi)
CREATE TABLE referensi_dokumen_koperasi (
    jenis_dokumen_ref VARCHAR(30) PRIMARY KEY,
    nama_dokumen      VARCHAR(200) NOT NULL,
    dibuat_pada       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. Outlet type reference (jenis gerai)
CREATE TABLE referensi_gerai_koperasi (
    jenis_gerai_ref  VARCHAR(30) PRIMARY KEY,
    nama_jenis_gerai VARCHAR(200) NOT NULL,
    dibuat_pada      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- MAIN ENTITIES
-- ============================================================================

-- 6. Cooperative profiles
CREATE TABLE profil_koperasi (
    koperasi_ref          VARCHAR(30)     PRIMARY KEY,
    nama_koperasi         VARCHAR(255)    NOT NULL,
    status_registrasi     VARCHAR(20)     NOT NULL DEFAULT 'Drafted',
    bentuk_koperasi       VARCHAR(50),
    kategori_usaha        VARCHAR(100),
    nik_koperasi          VARCHAR(30),
    alamat_lengkap        TEXT,
    kode_pos              VARCHAR(10),
    koordinat_dibulatkan  VARCHAR(50),
    modal_awal            NUMERIC(18,2)   DEFAULT 0,
    sumber_persetujuan    VARCHAR(50),
    tentang_koperasi      TEXT,
    pola_pengelolaan      VARCHAR(50),
    metode_pengisian      VARCHAR(50),
    dibuat_pada           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 7. Cooperative ↔ Wilayan mapping
CREATE TABLE referensi_koperasi_wilayah (
    koperasi_ref   VARCHAR(30)  NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    kode_wilayah   VARCHAR(20)  NOT NULL REFERENCES referensi_wilayah(kode_wilayah),
    dibuat_pada    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (koperasi_ref, kode_wilayah)
);

-- 8. Cooperative members
CREATE TABLE anggota_koperasi (
    anggota_ref          VARCHAR(30)   PRIMARY KEY,
    koperasi_ref         VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nama                 VARCHAR(150)  NOT NULL,
    nik                  VARCHAR(30),
    kode_wilayah         VARCHAR(20)   REFERENCES referensi_wilayah(kode_wilayah),
    jenis_kelamin        VARCHAR(20),
    status_keanggotaan   VARCHAR(20)   NOT NULL DEFAULT 'Requested',
    tanggal_terdaftar    DATE,
    file_ktp             VARCHAR(255),
    status_akun          VARCHAR(30),
    pekerjaan            VARCHAR(100),
    dibuat_pada          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 9. Cooperative board / management
CREATE TABLE pengurus_koperasi (
    pengurus_ref       VARCHAR(30)   PRIMARY KEY,
    koperasi_ref       VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nama               VARCHAR(150)  NOT NULL,
    jabatan            VARCHAR(100),
    status             VARCHAR(20)   NOT NULL DEFAULT 'PENGURUS',
    no_hp              VARCHAR(20),
    nik                VARCHAR(30),
    jenis_kelamin      VARCHAR(20),
    foto_profil        VARCHAR(255),
    email              VARCHAR(100),
    alamat             TEXT,
    kode_pos           VARCHAR(10),
    tanggal_lahir      DATE,
    status_pendidikan  VARCHAR(50),
    periode_mulai      DATE,
    periode_selesai    DATE,
    file_ktp           VARCHAR(255),
    sumber_data        VARCHAR(100),
    dibuat_pada        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 10. Member savings
CREATE TABLE simpanan_anggota (
    simpanan_ref      VARCHAR(30)   PRIMARY KEY,
    koperasi_ref      VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    anggota_ref       VARCHAR(30)   NOT NULL REFERENCES anggota_koperasi(anggota_ref),
    periode_pembayaran VARCHAR(100) NOT NULL,
    jumlah_simpanan   NUMERIC(18,2) NOT NULL DEFAULT 0,
    status            VARCHAR(10)   NOT NULL DEFAULT 'UNPAID',
    dibuat_pada       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dibayar_pada      TIMESTAMP
);

-- 11. Cooperative products
CREATE TABLE produk_koperasi (
    produk_sample_id VARCHAR(30)  PRIMARY KEY,
    koperasi_ref     VARCHAR(30)  NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    kode_barcode     VARCHAR(30),
    nama_produk      VARCHAR(200) NOT NULL,
    unit             VARCHAR(50),
    dibuat_pada      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 12. Sales transactions
CREATE TABLE transaksi_penjualan (
    transaksi_sample_id VARCHAR(30)  PRIMARY KEY,
    koperasi_ref        VARCHAR(30)  NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nama_pelanggan      VARCHAR(150),
    tanggal_dibuat      TIMESTAMP,
    total_pembayaran    NUMERIC(18,2) DEFAULT 0,
    status_transaksi    VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    metode_pembayaran   VARCHAR(50),
    dibuat_pada         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13. Sales line items (outgoing goods per transaction)
CREATE TABLE barang_keluar_produk (
    __row_id            SERIAL        PRIMARY KEY,
    transaksi_sample_id VARCHAR(30)   NOT NULL REFERENCES transaksi_penjualan(transaksi_sample_id),
    produk_sample_id    VARCHAR(30)   NOT NULL REFERENCES produk_koperasi(produk_sample_id),
    koperasi_ref        VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    kode_barcode        VARCHAR(30),
    tanggal_keluar      TIMESTAMP,
    status              VARCHAR(30)   NOT NULL DEFAULT 'Sales',
    nama_produk         VARCHAR(200),
    nama_tampilan       VARCHAR(200),
    jumlah_keluar       NUMERIC(12,2) DEFAULT 0,
    harga               NUMERIC(18,2) DEFAULT 0,
    total_nilai         NUMERIC(18,2) DEFAULT 0,
    status_transaksi    VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    dibuat_pada         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 14. Incoming goods (stock-in / purchase)
CREATE TABLE barang_masuk_produk (
    barang_masuk_ref  VARCHAR(30)   PRIMARY KEY,
    produk_sample_id  VARCHAR(30)   NOT NULL REFERENCES produk_koperasi(produk_sample_id),
    koperasi_ref      VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    kode_barcode      VARCHAR(30),
    nama_produk       VARCHAR(200),
    nama_tampilan     VARCHAR(200),
    jumlah_masuk      NUMERIC(12,2) DEFAULT 0,
    jumlah_tersedia   NUMERIC(12,2) DEFAULT 0,
    harga_beli        NUMERIC(18,2) DEFAULT 0,
    harga_jual        NUMERIC(18,2) DEFAULT 0,
    total_biaya       NUMERIC(18,2) DEFAULT 0,
    keterangan        TEXT,
    status            VARCHAR(20)   NOT NULL DEFAULT 'Approved',
    tanggal_masuk     TIMESTAMP,
    dibuat_pada       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 15. Product inventory
CREATE TABLE inventaris_produk (
    inventaris_ref    VARCHAR(30)   PRIMARY KEY,
    produk_sample_id  VARCHAR(30)   NOT NULL REFERENCES produk_koperasi(produk_sample_id),
    koperasi_ref      VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nama_produk       VARCHAR(200),
    stok              NUMERIC(12,2) DEFAULT 0,
    kode_barcode      VARCHAR(30),
    dibuat_pada       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 16. Cooperative bank accounts
CREATE TABLE akun_bank_koperasi (
    akun_bank_ref   VARCHAR(30)  PRIMARY KEY,
    koperasi_ref    VARCHAR(30)  NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nama_rekening   VARCHAR(150),
    nama_bank       VARCHAR(100) NOT NULL,
    dibuat_pada     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 17. Cooperative assets
CREATE TABLE aset_koperasi (
    aset_ref             VARCHAR(30)   PRIMARY KEY,
    koperasi_ref         VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nama_aset            VARCHAR(255)  NOT NULL,
    tipe_aset            VARCHAR(100),
    status               VARCHAR(30)   NOT NULL DEFAULT 'Belum Terverifikasi',
    progres_pembangunan  NUMERIC(5,2)  DEFAULT 0,
    foto_utama           VARCHAR(255),
    foto_sekunder        VARCHAR(255),
    dokumen_utama        VARCHAR(255),
    dokumen_sekunder     VARCHAR(255),
    dokumen_lainnya      VARCHAR(255),
    luas_lahan           NUMERIC(14,2) DEFAULT 0,
    panjang_lahan        NUMERIC(14,2) DEFAULT 0,
    lebar_lahan          NUMERIC(14,2) DEFAULT 0,
    akses_jalan          VARCHAR(100),
    koordinat_dibulatkan VARCHAR(50),
    dibuat_pada          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 18. Cooperative capital / funding
CREATE TABLE modal_koperasi (
    modal_ref          VARCHAR(30)   PRIMARY KEY,
    koperasi_ref       VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nomor_perjanjian   VARCHAR(100),
    tipe_sumber        VARCHAR(30),
    nama_sumber        VARCHAR(150),
    tipe_modal         VARCHAR(30),
    jumlah             NUMERIC(18,2) NOT NULL DEFAULT 0,
    tanggal_diterima   DATE,
    file_perjanjian    VARCHAR(255),
    dibuat_pada        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 19. Cooperative employees
CREATE TABLE karyawan_koperasi (
    karyawan_ref      VARCHAR(30)   PRIMARY KEY,
    koperasi_ref      VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nama              VARCHAR(150)  NOT NULL,
    jabatan           VARCHAR(100),
    nomor_hp_karyawan VARCHAR(20),
    jenis_kelamin     VARCHAR(20),
    nik               VARCHAR(30),
    email             VARCHAR(100),
    status_karyawan   VARCHAR(20)   NOT NULL DEFAULT 'Aktif',
    dibuat_pada       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 20. Cooperative outlets / stores
CREATE TABLE gerai_koperasi (
    gerai_ref                       VARCHAR(30)   PRIMARY KEY,
    koperasi_ref                    VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    jenis_gerai_ref                 VARCHAR(30)   REFERENCES referensi_gerai_koperasi(jenis_gerai_ref),
    status_gerai                    VARCHAR(20)   NOT NULL DEFAULT 'Belum Aktif',
    foto_gerai                      VARCHAR(255),
    pengisi                         VARCHAR(100),
    akses_internet                  VARCHAR(20),
    akses_listrik                   VARCHAR(20),
    status_kepemilikan_aset_gerai   VARCHAR(50),
    status_pemanfaatan_aset_gerai   VARCHAR(50),
    sumber_air_bersih               VARCHAR(50),
    jenis_bangunan                  VARCHAR(50),
    koordinat_dibulatkan            VARCHAR(50),
    dibuat_pada                     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada                 TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 21. KBLI business classification
CREATE TABLE kbli_koperasi (
    __row_id         SERIAL        PRIMARY KEY,
    koperasi_ref     VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    kode_kbli        VARCHAR(10)   NOT NULL,
    nama_kbli        TEXT          NOT NULL,
    tipe_izin_usaha  VARCHAR(100),
    tahun_kbli       VARCHAR(4),
    dibuat_pada      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 22. Cooperative documents
CREATE TABLE dokumen_koperasi (
    dokumen_ref         VARCHAR(30)   PRIMARY KEY,
    koperasi_ref        VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    jenis_dokumen_ref   VARCHAR(30)   NOT NULL REFERENCES referensi_dokumen_koperasi(jenis_dokumen_ref),
    nomor               VARCHAR(100),
    tanggal_berlaku     DATE,
    tanggal_kadaluarsa  DATE,
    alamat_pada_dokumen TEXT,
    unggahan_dokumen    VARCHAR(255),
    dibuat_pada         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PENGAJUAN (Applications / Submissions)
-- ============================================================================

-- 23. Domain name applications
CREATE TABLE pengajuan_domain (
    domain_ref       VARCHAR(30)  PRIMARY KEY,
    koperasi_ref     VARCHAR(30)  NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    domain_koperasi  VARCHAR(255) NOT NULL,
    status_verifikasi VARCHAR(20) NOT NULL DEFAULT 'Not Verified',
    status_domain    VARCHAR(20)  NOT NULL DEFAULT 'Waiting',
    dibuat_pada      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 24. Partnership applications
CREATE TABLE pengajuan_kemitraan (
    pengajuan_kemitraan_ref VARCHAR(30)   PRIMARY KEY,
    koperasi_ref            VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nik                     VARCHAR(30),
    penanggung_jawab        VARCHAR(150),
    nomor_penanggung_jawab  VARCHAR(20),
    status_permohonan       VARCHAR(20)   NOT NULL DEFAULT 'Requested',
    bisnis_kemitraan        VARCHAR(200),
    paket_kemitraan         VARCHAR(100),
    formulir_permohonan     VARCHAR(255),
    ktp_penanggung_jawab    VARCHAR(255),
    tipe_kemitraan          VARCHAR(50),
    catatan                 TEXT,
    dibuat_pada             TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 25. Financing / loan applications
CREATE TABLE pengajuan_pembiayaan (
    pengajuan_pembiayaan_ref   VARCHAR(30)   PRIMARY KEY,
    koperasi_ref               VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nik                        VARCHAR(30),
    penanggung_jawab           VARCHAR(150),
    nomor_penanggung_jawab     VARCHAR(20),
    status_permohonan          VARCHAR(20)   NOT NULL DEFAULT 'Requested',
    formulir_permohonan_pembiayaan VARCHAR(255),
    nominal_permohonan         NUMERIC(18,2) DEFAULT 0,
    tenor                      INTEGER       DEFAULT 0,
    tujuan_permohonan          VARCHAR(100),
    dibuat_pada                TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 26. Bank account opening applications
CREATE TABLE pengajuan_rekening_bank (
    pengajuan_rekening_ref VARCHAR(30)   PRIMARY KEY,
    koperasi_ref           VARCHAR(30)   NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    nik                    VARCHAR(30),
    penanggung_jawab       VARCHAR(150),
    nomor_penanggung_jawab VARCHAR(20),
    status                 VARCHAR(20)   NOT NULL DEFAULT 'Requested',
    kode_bank              VARCHAR(10),
    nama_bank              VARCHAR(100),
    dibuat_pada            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- RAT (Annual Member Meeting)
-- ============================================================================

-- 27. RAT — Annual member meeting with financial reports in JSONB
CREATE TABLE rat_koperasi (
    rat_sample_id             VARCHAR(30)  PRIMARY KEY,
    koperasi_ref              VARCHAR(30)  NOT NULL REFERENCES profil_koperasi(koperasi_ref),
    jenis_sektor_koperasi     VARCHAR(20)  NOT NULL DEFAULT 'KDKMP',
    urutan_rat                INTEGER      NOT NULL DEFAULT 1,
    tahun_buku                INTEGER,
    tahun_rencana_kerja       INTEGER,
    tahun_rencana_anggaran    INTEGER,
    tanggal_rat               DATE,
    jumlah_peserta_rat        INTEGER      DEFAULT 0,
    status_rat                VARCHAR(20)  NOT NULL DEFAULT 'Drafted',
    tahap_rat                 INTEGER      DEFAULT 0,
    laporan_posisi_keuangan   JSONB,
    laporan_hasil_usaha       JSONB,
    rapb_posisi_keuangan      JSONB,
    rapb_hasil_usaha          JSONB,
    dibuat_pada               TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- profil_koperasi
CREATE INDEX idx_profil_koperasi_status ON profil_koperasi(status_registrasi);
CREATE INDEX idx_profil_koperasi_nama ON profil_koperasi(nama_koperasi);

-- anggota_koperasi
CREATE INDEX idx_anggota_koperasi_ref ON anggota_koperasi(koperasi_ref);
CREATE INDEX idx_anggota_koperasi_nik ON anggota_koperasi(nik);
CREATE INDEX idx_anggota_koperasi_wilayah ON anggota_koperasi(kode_wilayah);
CREATE INDEX idx_anggota_koperasi_status ON anggota_koperasi(status_keanggotaan);

-- pengurus_koperasi
CREATE INDEX idx_pengurus_koperasi_ref ON pengurus_koperasi(koperasi_ref);
CREATE INDEX idx_pengurus_koperasi_jabatan ON pengurus_koperasi(jabatan);

-- simpanan_anggota
CREATE INDEX idx_simpanan_anggota_ref ON simpanan_anggota(koperasi_ref);
CREATE INDEX idx_simpanan_anggota_anggota ON simpanan_anggota(anggota_ref);
CREATE INDEX idx_simpanan_anggota_status ON simpanan_anggota(status);

-- produk_koperasi
CREATE INDEX idx_produk_koperasi_ref ON produk_koperasi(koperasi_ref);
CREATE INDEX idx_produk_koperasi_barcode ON produk_koperasi(kode_barcode);

-- transaksi_penjualan
CREATE INDEX idx_transaksi_penjualan_ref ON transaksi_penjualan(koperasi_ref);
CREATE INDEX idx_transaksi_penjualan_status ON transaksi_penjualan(status_transaksi);
CREATE INDEX idx_transaksi_penjualan_tanggal ON transaksi_penjualan(tanggal_dibuat);

-- barang_keluar_produk
CREATE INDEX idx_barang_keluar_transaksi ON barang_keluar_produk(transaksi_sample_id);
CREATE INDEX idx_barang_keluar_produk ON barang_keluar_produk(produk_sample_id);
CREATE INDEX idx_barang_keluar_koperasi ON barang_keluar_produk(koperasi_ref);

-- barang_masuk_produk
CREATE INDEX idx_barang_masuk_produk ON barang_masuk_produk(produk_sample_id);
CREATE INDEX idx_barang_masuk_koperasi ON barang_masuk_produk(koperasi_ref);
CREATE INDEX idx_barang_masuk_status ON barang_masuk_produk(status);

-- inventaris_produk
CREATE INDEX idx_inventaris_produk ON inventaris_produk(produk_sample_id);
CREATE INDEX idx_inventaris_koperasi ON inventaris_produk(koperasi_ref);

-- aset_koperasi
CREATE INDEX idx_aset_koperasi_ref ON aset_koperasi(koperasi_ref);
CREATE INDEX idx_aset_koperasi_status ON aset_koperasi(status);
CREATE INDEX idx_aset_koperasi_tipe ON aset_koperasi(tipe_aset);

-- akun_bank_koperasi
CREATE INDEX idx_akun_bank_koperasi_ref ON akun_bank_koperasi(koperasi_ref);

-- modal_koperasi
CREATE INDEX idx_modal_koperasi_ref ON modal_koperasi(koperasi_ref);
CREATE INDEX idx_modal_koperasi_tipe ON modal_koperasi(tipe_modal);

-- karyawan_koperasi
CREATE INDEX idx_karyawan_koperasi_ref ON karyawan_koperasi(koperasi_ref);
CREATE INDEX idx_karyawan_koperasi_status ON karyawan_koperasi(status_karyawan);

-- gerai_koperasi
CREATE INDEX idx_gerai_koperasi_ref ON gerai_koperasi(koperasi_ref);
CREATE INDEX idx_gerai_koperasi_status ON gerai_koperasi(status_gerai);

-- kbli_koperasi
CREATE INDEX idx_kbli_koperasi_ref ON kbli_koperasi(koperasi_ref);
CREATE INDEX idx_kbli_koperasi_kode ON kbli_koperasi(kode_kbli);

-- dokumen_koperasi
CREATE INDEX idx_dokumen_koperasi_ref ON dokumen_koperasi(koperasi_ref);
CREATE INDEX idx_dokumen_koperasi_jenis ON dokumen_koperasi(jenis_dokumen_ref);

-- pengajuan_*
CREATE INDEX idx_pengajuan_domain_koperasi ON pengajuan_domain(koperasi_ref);
CREATE INDEX idx_pengajuan_kemitraan_koperasi ON pengajuan_kemitraan(koperasi_ref);
CREATE INDEX idx_pengajuan_kemitraan_status ON pengajuan_kemitraan(status_permohonan);
CREATE INDEX idx_pengajuan_pembiayaan_koperasi ON pengajuan_pembiayaan(koperasi_ref);
CREATE INDEX idx_pengajuan_pembiayaan_status ON pengajuan_pembiayaan(status_permohonan);
CREATE INDEX idx_pengajuan_rekening_koperasi ON pengajuan_rekening_bank(koperasi_ref);
CREATE INDEX idx_pengajuan_rekening_status ON pengajuan_rekening_bank(status);

-- rat_koperasi
CREATE INDEX idx_rat_koperasi_ref ON rat_koperasi(koperasi_ref);
CREATE INDEX idx_rat_koperasi_tahun ON rat_koperasi(tahun_buku);
CREATE INDEX idx_rat_koperasi_status ON rat_koperasi(status_rat);

-- referensi
CREATE INDEX idx_referensi_wilayah_provinsi ON referensi_wilayah(provinsi);
CREATE INDEX idx_referensi_wilayah_kab_kota ON referensi_wilayah(kab_kota);
CREATE INDEX idx_referensi_komoditas_wilayah ON referensi_komoditas_desa(kode_wilayah);
CREATE INDEX idx_referensi_profil_desa_wilayah ON referensi_profil_desa(kode_wilayah);
CREATE INDEX idx_referensi_koperasi_wilayah_kode ON referensi_koperasi_wilayah(kode_wilayah);
