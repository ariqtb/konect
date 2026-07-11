# Database Schema Overview

This file documents the tables and columns currently present in the Supabase database.

## Table: `akun_bank_koperasi`

- `akun_bank_ref` (character varying)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `koperasi_ref` (character varying)
- `nama_bank` (character varying)
- `nama_rekening` (character varying)

## Table: `anggota_koperasi`

- `anggota_ref` (character varying)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `file_ktp` (character varying)
- `jenis_kelamin` (character varying)
- `kode_wilayah` (character varying)
- `koperasi_ref` (character varying)
- `nama` (character varying)
- `nik` (character varying)
- `pekerjaan` (character varying)
- `status_akun` (character varying)
- `status_keanggotaan` (character varying)
- `tanggal_terdaftar` (date)

## Table: `articles`

- `content` (text)
- `created_at` (timestamp with time zone)
- `created_by` (uuid)
- `id` (uuid)
- `image_url` (text)
- `title` (character varying)
- `updated_at` (timestamp with time zone)

## Table: `aset_koperasi`

- `akses_jalan` (character varying)
- `aset_ref` (character varying)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `dokumen_lainnya` (character varying)
- `dokumen_sekunder` (character varying)
- `dokumen_utama` (character varying)
- `foto_sekunder` (character varying)
- `foto_utama` (character varying)
- `koperasi_ref` (character varying)
- `latitude` (double precision)
- `lebar_lahan` (numeric)
- `longitude` (double precision)
- `luas_lahan` (numeric)
- `nama_aset` (character varying)
- `panjang_lahan` (numeric)
- `progres_pembangunan` (numeric)
- `status` (character varying)
- `tipe_aset` (character varying)

## Table: `banned_words`

- `category` (character varying)
- `created_at` (timestamp with time zone)
- `id` (uuid)
- `is_active` (boolean)
- `language` (character varying)
- `severity` (character varying)
- `word` (text)

## Table: `barang_keluar_produk`

- `__row_id` (integer)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `harga` (numeric)
- `jumlah_keluar` (numeric)
- `kode_barcode` (character varying)
- `koperasi_ref` (character varying)
- `nama_produk` (character varying)
- `nama_tampilan` (character varying)
- `produk_sample_id` (character varying)
- `status` (character varying)
- `status_transaksi` (character varying)
- `tanggal_keluar` (timestamp without time zone)
- `total_nilai` (numeric)
- `transaksi_sample_id` (character varying)

## Table: `barang_masuk_produk`

- `barang_masuk_ref` (character varying)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `harga_beli` (numeric)
- `harga_jual` (numeric)
- `jumlah_masuk` (numeric)
- `jumlah_tersedia` (numeric)
- `keterangan` (text)
- `kode_barcode` (character varying)
- `koperasi_ref` (character varying)
- `nama_produk` (character varying)
- `nama_tampilan` (character varying)
- `produk_sample_id` (character varying)
- `status` (character varying)
- `tanggal_masuk` (timestamp without time zone)
- `total_biaya` (numeric)

## Table: `discussion_rooms`

- `created_at` (timestamp with time zone)
- `created_by` (uuid)
- `description` (text)
- `embedding` (USER-DEFINED)
- `end_date` (timestamp with time zone)
- `id` (uuid)
- `is_active` (boolean)
- `is_anonymous` (boolean)
- `koperasi_ref` (character varying)
- `start_date` (timestamp with time zone)
- `title` (character varying)
- `updated_at` (timestamp with time zone)

## Table: `dokumen_koperasi`

- `alamat_pada_dokumen` (text)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `dokumen_ref` (character varying)
- `jenis_dokumen_ref` (character varying)
- `koperasi_ref` (character varying)
- `nomor` (character varying)
- `tanggal_berlaku` (date)
- `tanggal_kadaluarsa` (date)
- `unggahan_dokumen` (character varying)

## Table: `gerai_koperasi`

- `akses_internet` (character varying)
- `akses_listrik` (character varying)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `foto_gerai` (character varying)
- `gerai_ref` (character varying)
- `jenis_bangunan` (character varying)
- `jenis_gerai_ref` (character varying)
- `koperasi_ref` (character varying)
- `latitude` (double precision)
- `longitude` (double precision)
- `pengisi` (character varying)
- `radius` (double precision)
- `status_gerai` (character varying)
- `status_kepemilikan_aset_gerai` (character varying)
- `status_pemanfaatan_aset_gerai` (character varying)
- `sumber_air_bersih` (character varying)

## Table: `inventaris_produk`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `inventaris_ref` (character varying)
- `kode_barcode` (character varying)
- `koperasi_ref` (character varying)
- `nama_produk` (character varying)
- `produk_sample_id` (character varying)
- `stok` (numeric)

## Table: `karyawan_koperasi`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `email` (character varying)
- `jabatan` (character varying)
- `jenis_kelamin` (character varying)
- `karyawan_ref` (character varying)
- `koperasi_ref` (character varying)
- `nama` (character varying)
- `nik` (character varying)
- `nomor_hp_karyawan` (character varying)
- `password` (character varying)
- `status_karyawan` (character varying)
- `user_uuid` (uuid)

## Table: `kbli_koperasi`

- `__row_id` (integer)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `kode_kbli` (character varying)
- `koperasi_ref` (character varying)
- `nama_kbli` (text)
- `tahun_kbli` (character varying)
- `tipe_izin_usaha` (character varying)

## Table: `modal_koperasi`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `file_perjanjian` (character varying)
- `jumlah` (numeric)
- `koperasi_ref` (character varying)
- `modal_ref` (character varying)
- `nama_sumber` (character varying)
- `nomor_perjanjian` (character varying)
- `tanggal_diterima` (date)
- `tipe_modal` (character varying)
- `tipe_sumber` (character varying)

## Table: `node_graph`

- `cluster` (character varying)
- `edge_type` (character varying)
- `edge_weight` (numeric)
- `label` (character varying)
- `node_id` (text)
- `node_type` (character varying)
- `parent_id` (uuid)
- `relevance_score` (numeric)
- `row_type` (character varying)
- `source_id` (text)
- `target_id` (text)
- `topic_id` (uuid)

## Table: `opinion_comments`

- `content` (text)
- `created_at` (timestamp with time zone)
- `embedding` (USER-DEFINED)
- `id` (uuid)
- `is_anonymous` (boolean)
- `latitude` (numeric)
- `longitude` (numeric)
- `opinion_id` (uuid)
- `parent_id` (uuid)
- `relevance_score` (numeric)
- `updated_at` (timestamp with time zone)
- `user_id` (bigint)

## Table: `opinions`

- `content` (text)
- `created_at` (timestamp with time zone)
- `embedding` (USER-DEFINED)
- `id` (uuid)
- `is_anonymous` (boolean)
- `latitude` (numeric)
- `longitude` (numeric)
- `relevance_score` (numeric)
- `room_id` (uuid)
- `updated_at` (timestamp with time zone)
- `user_id` (bigint)

## Table: `pengajuan_domain`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `domain_koperasi` (character varying)
- `domain_ref` (character varying)
- `koperasi_ref` (character varying)
- `status_domain` (character varying)
- `status_verifikasi` (character varying)

## Table: `pengajuan_kemitraan`

- `bisnis_kemitraan` (character varying)
- `catatan` (text)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `formulir_permohonan` (character varying)
- `koperasi_ref` (character varying)
- `ktp_penanggung_jawab` (character varying)
- `nik` (character varying)
- `nomor_penanggung_jawab` (character varying)
- `paket_kemitraan` (character varying)
- `penanggung_jawab` (character varying)
- `pengajuan_kemitraan_ref` (character varying)
- `status_permohonan` (character varying)
- `tipe_kemitraan` (character varying)

## Table: `pengajuan_pembiayaan`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `formulir_permohonan_pembiayaan` (character varying)
- `koperasi_ref` (character varying)
- `nik` (character varying)
- `nominal_permohonan` (numeric)
- `nomor_penanggung_jawab` (character varying)
- `penanggung_jawab` (character varying)
- `pengajuan_pembiayaan_ref` (character varying)
- `status_permohonan` (character varying)
- `tenor` (integer)
- `tujuan_permohonan` (character varying)

## Table: `pengajuan_rekening_bank`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `kode_bank` (character varying)
- `koperasi_ref` (character varying)
- `nama_bank` (character varying)
- `nik` (character varying)
- `nomor_penanggung_jawab` (character varying)
- `penanggung_jawab` (character varying)
- `pengajuan_rekening_ref` (character varying)
- `status` (character varying)

## Table: `pengurus_koperasi`

- `alamat` (text)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `email` (character varying)
- `file_ktp` (character varying)
- `foto_profil` (character varying)
- `jabatan` (character varying)
- `jenis_kelamin` (character varying)
- `kode_pos` (character varying)
- `koperasi_ref` (character varying)
- `nama` (character varying)
- `nik` (character varying)
- `no_hp` (character varying)
- `pengurus_ref` (character varying)
- `periode_mulai` (date)
- `periode_selesai` (date)
- `status` (character varying)
- `status_pendidikan` (character varying)
- `sumber_data` (character varying)
- `tanggal_lahir` (date)

## Table: `point_transactions`

- `amount` (integer)
- `created_at` (timestamp with time zone)
- `description` (text)
- `id` (uuid)
- `reference_id` (uuid)
- `transaction_type` (USER-DEFINED)
- `user_id` (uuid)

## Table: `produk_koperasi`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `kode_barcode` (character varying)
- `koperasi_ref` (character varying)
- `nama_produk` (character varying)
- `produk_sample_id` (character varying)
- `unit` (character varying)

## Table: `profil_koperasi`

- `alamat_lengkap` (text)
- `bentuk_koperasi` (character varying)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `kategori_usaha` (character varying)
- `kode_pos` (character varying)
- `koperasi_ref` (character varying)
- `latitude` (double precision)
- `longitude` (double precision)
- `metode_pengisian` (character varying)
- `modal_awal` (numeric)
- `nama_koperasi` (character varying)
- `nik_koperasi` (character varying)
- `pola_pengelolaan` (character varying)
- `status_registrasi` (character varying)
- `sumber_persetujuan` (character varying)
- `tentang_koperasi` (text)

## Table: `rat_koperasi`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `jenis_sektor_koperasi` (character varying)
- `jumlah_peserta_rat` (integer)
- `koperasi_ref` (character varying)
- `laporan_hasil_usaha` (jsonb)
- `laporan_posisi_keuangan` (jsonb)
- `rapb_hasil_usaha` (jsonb)
- `rapb_posisi_keuangan` (jsonb)
- `rat_sample_id` (character varying)
- `status_rat` (character varying)
- `tahap_rat` (integer)
- `tahun_buku` (integer)
- `tahun_rencana_anggaran` (integer)
- `tahun_rencana_kerja` (integer)
- `tanggal_rat` (date)
- `urutan_rat` (integer)

## Table: `reactions`

- `created_at` (timestamp with time zone)
- `id` (uuid)
- `reaction` (USER-DEFINED)
- `target_id` (uuid)
- `target_type` (character varying)
- `user_id` (uuid)

## Table: `referensi_dokumen_koperasi`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `jenis_dokumen_ref` (character varying)
- `nama_dokumen` (character varying)

## Table: `referensi_gerai_koperasi`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `jenis_gerai_ref` (character varying)
- `nama_jenis_gerai` (character varying)

## Table: `referensi_komoditas_desa`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `jumlah_sdm_terlibat` (integer)
- `kode_wilayah` (character varying)
- `komoditas_ref` (character varying)
- `luas_area` (character varying)
- `nama_komoditas` (text)
- `nilai_potensi_desa` (numeric)
- `volume` (character varying)

## Table: `referensi_koperasi_wilayah`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `kode_wilayah` (character varying)
- `koperasi_ref` (character varying)

## Table: `referensi_profil_desa`

- `anggaran_dana_desa` (numeric)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `kode_wilayah` (character varying)
- `penduduk_laki_laki` (integer)
- `penduduk_perempuan` (integer)
- `tahun_pendanaan` (integer)
- `tahun_populasi` (integer)
- `total_penduduk` (integer)

## Table: `referensi_wilayah`

- `desa_kelurahan` (character varying)
- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `kab_kota` (character varying)
- `kecamatan` (character varying)
- `kode_wilayah` (character varying)
- `provinsi` (character varying)

## Table: `room_participants`

- `id` (uuid)
- `joined_at` (timestamp with time zone)
- `role` (character varying)
- `room_id` (uuid)
- `user_id` (uuid)

## Table: `simpanan_anggota`

- `anggota_ref` (character varying)
- `dibayar_pada` (timestamp without time zone)
- `dibuat_pada` (timestamp without time zone)
- `jumlah_simpanan` (numeric)
- `koperasi_ref` (character varying)
- `periode_pembayaran` (character varying)
- `simpanan_ref` (character varying)
- `status` (character varying)

## Table: `transaksi_penjualan`

- `dibuat_pada` (timestamp without time zone)
- `diperbarui_pada` (timestamp without time zone)
- `koperasi_ref` (character varying)
- `metode_pembayaran` (character varying)
- `nama_pelanggan` (character varying)
- `status_transaksi` (character varying)
- `tanggal_dibuat` (timestamp without time zone)
- `total_pembayaran` (numeric)
- `transaksi_sample_id` (character varying)

## Table: `users`

- `created_at` (timestamp with time zone)
- `points` (integer)
- `uuid` (bigint)

## Table: `villages`

- `address` (text)
- `created_at` (timestamp with time zone)
- `description` (text)
- `id` (uuid)
- `is_active` (boolean)
- `logo_url` (text)
- `name` (character varying)
- `slug` (character varying)
- `updated_at` (timestamp with time zone)

## Table: `voucher_redemptions`

- `created_at` (timestamp with time zone)
- `id` (uuid)
- `qr_code_used` (text)
- `redeemed_at` (timestamp with time zone)
- `status` (USER-DEFINED)
- `user_id` (uuid)
- `voucher_id` (uuid)

## Table: `vouchers`

- `code` (character varying)
- `cooperative_id` (uuid)
- `created_at` (timestamp with time zone)
- `description` (text)
- `expires_at` (timestamp with time zone)
- `id` (uuid)
- `is_active` (boolean)
- `points_required` (integer)
- `qr_code_url` (text)
- `quantity` (integer)
- `title` (character varying)
- `updated_at` (timestamp with time zone)

## Custom RPC Functions

### `get_room_canvas(p_room_id UUID)`
Returns the room details and associated opinions/comments.
```sql
CREATE OR REPLACE FUNCTION get_room_canvas(p_room_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_topic JSONB;
    v_opinions JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', dr.id,
        'title', dr.title,
        'description', dr.description,
        'code', dr.code,
        'is_active', dr.is_active,
        'is_anonymous', dr.is_anonymous,
        'cooperative_ref', dr.koperasi_ref,
        'cooperative_name', (
            SELECT nama_koperasi FROM profil_koperasi
            WHERE koperasi_ref = dr.koperasi_ref
        ),
        'created_by', dr.created_by,
        'created_at', dr.created_at
    ) INTO v_topic
    FROM discussion_rooms dr
    WHERE dr.id = p_room_id;

    IF v_topic IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(jsonb_agg(opinion_data ORDER BY o_created_at ASC), '[]'::jsonb)
        INTO v_opinions
    FROM (
        SELECT
            jsonb_build_object(
                'id', o.id,
                'text', o.content,
                'is_anonymous', o.is_anonymous,
                'user_id', o.user_id,
                'author_name', CASE WHEN o.is_anonymous THEN 'Anonim' ELSE 'Warga' END,
                'likes', (SELECT COUNT(*) FROM reactions r
                            WHERE r.target_type = 'opinion' AND r.target_id = o.id
                              AND r.reaction = 'like')::INTEGER,
                'agree_count', (SELECT COUNT(*) FROM reactions r
                            WHERE r.target_type = 'opinion' AND r.target_id = o.id
                              AND r.reaction = 'agree')::INTEGER,
                'disagree_count', (SELECT COUNT(*) FROM reactions r
                            WHERE r.target_type = 'opinion' AND r.target_id = o.id
                              AND r.reaction = 'disagree')::INTEGER,
                'comments', COALESCE((
                    SELECT jsonb_agg(dc.content ORDER BY dc.created_at ASC)
                    FROM opinion_comments dc
                    WHERE dc.opinion_id = o.id
                ), '[]'::jsonb),
                'created_at', o.created_at,
                'latitude', o.latitude,
                'longitude', o.longitude,
                'relevance_score', o.relevance_score
            ) AS opinion_data,
            o.created_at AS o_created_at
        FROM opinions o
        WHERE o.room_id = p_room_id
    ) opinions_with_meta;

    RETURN v_topic || jsonb_build_object('opinions', v_opinions);
END;
$$ LANGUAGE plpgsql STABLE;
```

### `get_cooperative_detail(p_coop_ref VARCHAR)`
Returns details of a cooperative, room discussions, and updates/articles.
```sql
CREATE OR REPLACE FUNCTION get_cooperative_detail(p_coop_ref VARCHAR)
RETURNS JSONB AS $$
DECLARE
    v_profil JSONB;
    v_rooms JSONB;
    v_updates JSONB;
BEGIN
    SELECT jsonb_build_object(
        'coop_id',       pk.koperasi_ref,
        'name',          pk.nama_koperasi,
        'address',       pk.alamat_lengkap,
        'description',   pk.tentang_koperasi,
        'category',      pk.kategori_usaha,
        'is_open',       (pk.status_registrasi = 'Approved'),
        'legal_status',  pk.bentuk_koperasi,
        'phone', (
            SELECT kk.nomor_hp_karyawan FROM karyawan_koperasi kk
            WHERE kk.koperasi_ref = pk.koperasi_ref
            LIMIT 1
        ),
        'email', (
            SELECT kk.email FROM karyawan_koperasi kk
            WHERE kk.koperasi_ref = pk.koperasi_ref
            LIMIT 1
        ),
        'image_url', NULL::TEXT,
        'chairperson', (
            SELECT p.nama FROM pengurus_koperasi p
            WHERE p.koperasi_ref = pk.koperasi_ref AND p.jabatan = 'Ketua'
            ORDER BY p.periode_mulai DESC NULLS LAST LIMIT 1
        ),
        'member_count', (
            SELECT COUNT(*) FROM anggota_koperasi ak
            WHERE ak.koperasi_ref = pk.koperasi_ref
        )
    ) INTO v_profil
    FROM profil_koperasi pk
    WHERE pk.koperasi_ref = p_coop_ref;

    IF v_profil IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(jsonb_agg(room_data ORDER BY dr_created_at DESC), '[]'::jsonb)
        INTO v_rooms
    FROM (
        SELECT
            jsonb_build_object(
                'id', dr.id,
                'title', dr.title,
                'description', dr.description,
                'status', CASE WHEN dr.is_active THEN 'Aktif' ELSE 'Selesai' END,
                'date', to_char(dr.created_at, 'DD Mon YYYY'),
                'start_date', to_char(dr.start_date, 'DD Mon YYYY'),
                'end_date', to_char(dr.end_date, 'DD Mon YYYY'),
                'members_count', (SELECT COUNT(*) FROM room_participants rp WHERE rp.room_id = dr.id),
                'avatars', '[]'::jsonb
            ) AS room_data,
            dr.created_at AS dr_created_at
        FROM discussion_rooms dr
        WHERE dr.koperasi_ref = p_coop_ref
    ) rooms;

    SELECT COALESCE(jsonb_agg(update_data ORDER BY a_created_at DESC), '[]'::jsonb)
        INTO v_updates
    FROM (
        SELECT
            jsonb_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.content,
                'date', to_char(a.created_at, 'DD Mon YYYY'),
                'type', 'info'
            ) AS update_data,
            a.created_at AS a_created_at
        FROM articles a
        LEFT JOIN karyawan_koperasi kk ON kk.user_uuid = a.created_by
        WHERE kk.koperasi_ref = p_coop_ref OR kk.koperasi_ref IS NULL
        LIMIT 10
    ) updates;

    RETURN v_profil
        || jsonb_build_object('rooms', v_rooms, 'updates', v_updates);
END;
$$ LANGUAGE plpgsql STABLE;
```

### `update_user_points_on_opinion()`
Automatically awards points to user based on relevance score of submitted opinion.
```sql
CREATE OR REPLACE FUNCTION public.update_user_points_on_opinion()
RETURNS trigger AS $$
BEGIN
    IF NEW.relevance_score IS NOT NULL AND NEW.user_id IS NOT NULL THEN
        UPDATE public.users
        SET points = COALESCE(points, 0) + (NEW.relevance_score * 10)::INTEGER
        WHERE uuid = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_update_user_points_on_opinion
AFTER INSERT OR UPDATE OF relevance_score ON public.opinions
FOR EACH ROW EXECUTE FUNCTION public.update_user_points_on_opinion();
```

### Table Privileges
Table privileges granted to allow client-side Supabase keys (anon/authenticated) to interact with tables.
```sql
GRANT ALL PRIVILEGES ON public.users TO anon;
GRANT ALL PRIVILEGES ON public.users TO authenticated;
GRANT ALL PRIVILEGES ON public.users TO service_role;
```
