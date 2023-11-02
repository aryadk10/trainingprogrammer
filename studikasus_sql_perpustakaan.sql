-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 02, 2023 at 06:32 PM
-- Server version: 10.4.17-MariaDB
-- PHP Version: 7.3.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `perpustakaan`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `pinjaman_anggota` (IN `id_anggota` INT)  begin
	select buku.judul,peminjaman_filtered.* from ( select * from perpustakaan.peminjaman where peminjaman.id_anggota = id_anggota ) as peminjaman_filtered left join perpustakaan.buku on peminjaman_filtered.id_buku = buku.id_buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pinjam_buku` (IN `id_anggota` INT, IN `id_buku` INT, IN `tgl_pinjam` DATE, IN `lama_pinjam` INT, IN `keterangan` VARCHAR(100))  begin
	DECLARE stok_buku INT;
DECLARE tgl_jatuh_tempo INT;
	select stok into stok_buku from perpustakaan.buku where buku.id_buku = id_buku limit 1;
	IF stok_buku > 0 then
	

    SELECT DATE_ADD(tgl_pinjam, INTERVAL lama_pinjam DAY) into tgl_jatuh_tempo;
	
	INSERT INTO perpustakaan.peminjaman
(id_buku, id_anggota, tgl_pinjam, tgl_jatuh_tempo, tgl_kembali, keterangan)
VALUES(id_buku, id_anggota, tgl_pinjam, tgl_jatuh_tempo, NULL, keterangan);

	select 'Sukses menambahkan buku' as message;
	else
	select 'Gagal menambahkan buku , buku tidak cukup' as message;
	end if;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `anggota`
--

CREATE TABLE `anggota` (
  `id_anggota` bigint(20) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `tgl_lahir` date DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `no_hp` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `anggota`
--

INSERT INTO `anggota` (`id_anggota`, `nama`, `tgl_lahir`, `alamat`, `email`, `no_hp`) VALUES
(1, 'John Doe', '1980-05-15', 'Jalan Sudirman No. 123, Jakarta', 'johndoe@example.com', '1234567890'),
(2, 'Jane Smith', '1995-09-20', 'Jalan Gatot Subroto No. 456, Surabaya', 'janesmith@example.com', '9876543210'),
(3, 'David Brown', '1988-03-10', 'Jalan M.H. Thamrin No. 789, Bandung', 'davidbrown@example.com', '5551234567'),
(4, 'Sarah Davis', '1992-07-25', 'Jalan Diponegoro No. 101, Yogyakarta', 'sarahdavis@example.com', '9998887777'),
(5, 'Michael Wilson', '1982-12-30', 'Jalan Pemuda No. 111, Medan', 'michaelwilson@example.com', '1112223333'),
(6, 'Emily Johnson', '1990-04-05', 'Jalan Thamrin No. 222, Semarang', 'emilyjohnson@example.com', '4445556666'),
(7, 'Richard Martin', '1985-06-14', 'Jalan Merdeka No. 333, Palembang', 'richardmartin@example.com', '7776665555'),
(8, 'Susan Anderson', '1987-08-18', 'Jalan Diponegoro No. 444, Makassar', 'susananderson@example.com', '8887778888'),
(9, 'Maria Garcia', '1998-01-22', 'Jalan Gatot Subroto No. 555, Denpasar', 'mariagarcia@example.com', '6669991111'),
(10, 'Matthew Hall', '1996-11-05', 'Jalan Pahlawan No. 666, Malang', 'matthewhall@example.com', '1231231234');

-- --------------------------------------------------------

--
-- Table structure for table `buku`
--

CREATE TABLE `buku` (
  `id_buku` bigint(20) NOT NULL,
  `judul` varchar(100) DEFAULT NULL,
  `pengarang` varchar(100) DEFAULT NULL,
  `stok` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `buku`
--

INSERT INTO `buku` (`id_buku`, `judul`, `pengarang`, `stok`) VALUES
(1, 'Pemrograman Python', 'John Smith', 5),
(2, 'Sejarah Dunia Modern', 'Emily Johnson', 2),
(3, 'Ilmu Komputer Dasar', 'David Brown', 8),
(4, 'Kisah Perjalanan', 'Sarah Davis', 10),
(5, 'Seni Melukis Abstrak', 'Michael Wilson', 2),
(6, 'Fisika Modern', 'Susan Anderson', 6),
(7, 'Bisnis Sukses', 'Richard Martin', 7),
(8, 'Sastra Klasik', 'Laura Taylor', 4),
(9, 'Keuangan Pribadi', 'Matthew Hall', 10),
(10, 'Pengembangan Web', 'Maria Garcia', 4);

--
-- Triggers `buku`
--
DELIMITER $$
CREATE TRIGGER `log_buku` AFTER UPDATE ON `buku` FOR EACH ROW begin
	declare selisih int;
    declare keterangan varchar(100);
    set selisih = new.stok - old.stok;
    if selisih > 0 then
    select concat('penambahan sebanyak ', selisih,' buku pada buku ', new.judul) into keterangan;
    else
    select concat('pengurangan sebanyak ', selisih,' buku pada buku ', new.judul) into keterangan;
    end if;
	INSERT INTO perpustakaan.log_buku
(id_buku, tgl_log, perubahan_stok, keterangan)
VALUES(new.id_buku,NOW(),selisih, keterangan);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `log_buku`
--

CREATE TABLE `log_buku` (
  `log_id` bigint(20) NOT NULL,
  `id_buku` bigint(20) DEFAULT NULL,
  `tgl_log` date DEFAULT NULL,
  `perubahan_stok` bigint(20) DEFAULT NULL,
  `keterangan` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `log_buku`
--

INSERT INTO `log_buku` (`log_id`, `id_buku`, `tgl_log`, `perubahan_stok`, `keterangan`) VALUES
(1, 10, '2023-11-02', 4, NULL),
(2, 10, '2023-11-02', -2, NULL),
(3, 10, '2023-11-02', 1, 'penambahan sebanyak 1 buku pada bukuPengembangan Web'),
(4, 9, '2023-11-02', 1, 'penambahan sebanyak 1 buku pada buku Keuangan Pribadi'),
(5, 2, '2023-11-02', -1, 'pengurangan sebanyak -1 buku pada buku Sejarah Dunia Modern');

-- --------------------------------------------------------

--
-- Table structure for table `peminjaman`
--

CREATE TABLE `peminjaman` (
  `id_peminjaman` bigint(20) NOT NULL,
  `id_buku` bigint(20) DEFAULT NULL,
  `id_anggota` bigint(20) DEFAULT NULL,
  `tgl_pinjam` date DEFAULT NULL,
  `tgl_jatuh_tempo` date DEFAULT NULL,
  `tgl_kembali` date DEFAULT NULL,
  `keterangan` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `peminjaman`
--

INSERT INTO `peminjaman` (`id_peminjaman`, `id_buku`, `id_anggota`, `tgl_pinjam`, `tgl_jatuh_tempo`, `tgl_kembali`, `keterangan`) VALUES
(1, 1, 1, '2023-11-02', '2023-11-16', NULL, 'Dipinjam'),
(2, 2, 2, '2023-11-03', '2023-11-17', NULL, 'Dipinjam'),
(3, 3, 3, '2023-11-04', '2023-11-18', NULL, 'Dipinjam'),
(4, 4, 4, '2023-11-05', '2023-11-19', NULL, 'Dipinjam'),
(5, 5, 5, '2023-11-06', '2023-11-20', NULL, 'Dipinjam'),
(6, 6, 6, '2023-11-07', '2023-11-21', NULL, 'Dipinjam'),
(7, 7, 7, '2023-11-08', '2023-11-22', NULL, 'Dipinjam'),
(8, 8, 8, '2023-11-09', '2023-11-23', NULL, 'Dipinjam'),
(9, 9, 9, '2023-11-10', '2023-11-24', NULL, 'Dipinjam'),
(10, 10, 10, '2023-11-11', '2023-11-25', NULL, 'Dipinjam'),
(32, 1, 1, '2023-11-11', '2023-11-21', NULL, 'dipinjam'),
(33, 2, 9, '2023-11-11', '2023-11-21', NULL, 'dipinjam'),
(34, 2, 9, '2023-11-11', '2023-11-21', NULL, 'dipinjam');

--
-- Triggers `peminjaman`
--
DELIMITER $$
CREATE TRIGGER `update_stok_after_kembali` AFTER UPDATE ON `peminjaman` FOR EACH ROW begin
	declare new_stok INT;
	if old.tgl_kembali IS null AND new.tgl_kembali is not null then 
	    select stok+1 into new_stok from perpustakaan.buku where buku.id_buku = NEW.id_buku;
		UPDATE perpustakaan.buku
		SET stok=new_stok
		WHERE id_buku=NEW.id_buku;
	end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_stok_after_pinjam` AFTER INSERT ON `peminjaman` FOR EACH ROW begin
	declare new_stok INT;
    select stok-1 into new_stok from perpustakaan.buku where buku.id_buku = NEW.id_buku;
	UPDATE perpustakaan.buku
	SET stok=new_stok
	WHERE id_buku=NEW.id_buku;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `pivot_summary_anggota`
-- (See below for the actual view)
--
CREATE TABLE `pivot_summary_anggota` (
`nama` varchar(100)
,`jumlah_buku` bigint(21)
,`jumlah_pinjaman` bigint(21)
,`masih_dipinjam` decimal(22,0)
,`sudah_dikembalikan` decimal(22,0)
);

-- --------------------------------------------------------

--
-- Structure for view `pivot_summary_anggota`
--
DROP TABLE IF EXISTS `pivot_summary_anggota`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `pivot_summary_anggota`  AS SELECT `a`.`nama` AS `nama`, count(distinct `p`.`id_buku`) AS `jumlah_buku`, count(0) AS `jumlah_pinjaman`, sum(if(`p`.`tgl_kembali` is not null,0,1)) AS `masih_dipinjam`, sum(if(`p`.`tgl_kembali` is null,0,1)) AS `sudah_dikembalikan` FROM (`peminjaman` `p` left join `anggota` `a` on(`p`.`id_anggota` = `a`.`id_anggota`)) GROUP BY `a`.`nama` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `anggota`
--
ALTER TABLE `anggota`
  ADD PRIMARY KEY (`id_anggota`);

--
-- Indexes for table `buku`
--
ALTER TABLE `buku`
  ADD PRIMARY KEY (`id_buku`);

--
-- Indexes for table `log_buku`
--
ALTER TABLE `log_buku`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD PRIMARY KEY (`id_peminjaman`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `anggota`
--
ALTER TABLE `anggota`
  MODIFY `id_anggota` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `buku`
--
ALTER TABLE `buku`
  MODIFY `id_buku` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `log_buku`
--
ALTER TABLE `log_buku`
  MODIFY `log_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `peminjaman`
--
ALTER TABLE `peminjaman`
  MODIFY `id_peminjaman` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
