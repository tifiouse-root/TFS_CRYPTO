CREATE TABLE `tfs_crypto` (
  `id` int(11) NOT NULL,
  `owner` varchar(46) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coords` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `finance` text COLLATE utf8mb4_unicode_ci NOT NULL
);

ALTER TABLE `tfs_crypto`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `tfs_crypto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;