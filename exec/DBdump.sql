CREATE DATABASE  IF NOT EXISTS `kdkd` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `kdkd`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: j13e106.p.ssafy.io    Database: kdkd
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `account_seq` bigint NOT NULL AUTO_INCREMENT,
  `account_number` varbinary(512) NOT NULL,
  `virtual_card` varbinary(512) DEFAULT NULL,
  `virtual_card_cvc` varbinary(512) DEFAULT NULL,
  `user_uuid` char(36) NOT NULL,
  `account_password` varbinary(512) NOT NULL,
  `total_use_payment` int DEFAULT '0',
  `bank_name` varchar(10) NOT NULL,
  PRIMARY KEY (`account_seq`),
  UNIQUE KEY `uq_account_number` (`account_number`),
  UNIQUE KEY `uq_account_virtual_card` (`virtual_card`),
  KEY `fk_account_user` (`user_uuid`),
  CONSTRAINT `fk_account_user` FOREIGN KEY (`user_uuid`) REFERENCES `user` (`user_uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES (22,_binary 'J.\'��\�5�уH�Ƭ\�٢\�\�\�\�6�qx�.\Z E',_binary 'J.\'�\�\�g=�a\�O7�\�E\0�nmzo���ؒ�\�^�',_binary 'J.\'�\�U�\�h�<��pȚ�g>��)','546e7ca0-5ae6-471c-84fe-81bea9ca67dc',_binary 'J.\'�GH�\r�� �&���O�\�yyb',0,'싸피은행'),(35,_binary 'J.\'����=\�,R�E�ܠ�A00\0�S�\�e\\\�\Zv\�P',_binary 'J.\'�\�ڲ�+\r=�#.jX�o��{�7t}ٝ�Ga',_binary 'J.\'�\���\�-\�%\�\�b�>4(8\�','5444880f-d9a9-4beb-999f-464e86763d63',_binary 'J.\'�GH�\r�� �&���O�\�yyb',0,'싸피은행'),(40,_binary 'J.\'�\�(�6���N���u\�\\n2\�\�\�\�\�Ϛ\0���5',_binary 'J.\'�\�v�O\�\��\�\�A8\��@L��\�Y�ӥ\�A',_binary 'J.\'�\�U$��l�\�\�\�bӛ\�L\Z�2','eef34aa6-af0b-4fbd-af4d-72da087ba601',_binary 'J.\'�7�\��\�����p���RB�\�F',0,'싸피은행'),(47,_binary 'J.\'�h\�B����\��r\��S��\�J\�`�?&\�z5��\0\�',_binary 'J.\'�<�R\��O\�\�\�\�È*O�jN�\�k\�\�\�',_binary 'J.\'���\�̅�$\�\�Av3A�\�h�','3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e',_binary 'J.\'�\�o\�(Zx\�8r\0�\�\�^*��kg',0,'싸피은행'),(48,_binary 'J.\'��\���B�ȗ����7�\�/w�XLC�\�|\�',_binary 'J.\'���\�\�m���J\�1l���ǈ\�\��4\�s��\\\�<%',_binary 'J.\'�3�un����Z#8׭��\�','8209e1e7-8f36-49a8-a3e3-ddf83a87f8e3',_binary 'J.\'�GH�\r�� �&���O�\�yyb',0,'싸피은행'),(49,_binary 'J.\'�g��\�5��\� XF�̄\�cx9=	23�\�%vl�K',_binary 'J.\'����\�\�?�\�\�~=\�s\�u�R�O&����*D��',_binary 'J.\'�\�\Zu7{���\'\n-\�7V\�}�','16e8c50d-43ff-4e1a-8077-17c13b108c5f',_binary 'J.\'�3�(ɕ\�\�Cf�}\�8�(',0,'싸피은행'),(50,_binary 'J.\'�����(s\�W:E<v\�*xie�]��\�4s\��s',_binary 'J.\'�2�[\�-�r�n(\�aB�g՛��y�\�X\n�j\�%K\'',_binary 'J.\'��<�bo<��Y��5\�\�\�9Ը\n','8341cbc6-0b00-4acf-b93e-6e4f4002c861',_binary 'J.\'�3�(ɕ\�\�Cf�}\�8�(',0,'싸피은행');
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_item`
--

DROP TABLE IF EXISTS `account_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_item` (
  `account_item_seq` bigint NOT NULL AUTO_INCREMENT,
  `account_seq` bigint NOT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `transaction_unique_no` bigint NOT NULL COMMENT '거래고유번호',
  `category_id` varchar(20) NOT NULL COMMENT '카테고리ID',
  `category_name` varchar(255) NOT NULL COMMENT '카테고리명',
  `merchant_id` bigint NOT NULL COMMENT '가맹점ID',
  `merchant_name` varchar(100) NOT NULL COMMENT '가맹점명',
  `transacted_at` datetime NOT NULL COMMENT '거래일시(YYYY-MM-DD HH:MM:SS)',
  `payment_balance` bigint NOT NULL COMMENT '거래금액',
  PRIMARY KEY (`account_item_seq`),
  KEY `idx_account_item_account` (`account_seq`),
  CONSTRAINT `fk_accountitem_account` FOREIGN KEY (`account_seq`) REFERENCES `account` (`account_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_item`
--

LOCK TABLES `account_item` WRITE;
/*!40000 ALTER TABLE `account_item` DISABLE KEYS */;
INSERT INTO `account_item` VALUES (1,35,37.5665,126.978,202509230001,'CG-9ca85f66311a23d','생활',14890,'스cu편의점 서울역점','2025-09-23 11:20:15',4800),(2,35,37.4979,127.0276,202509230002,'CG-9ca85f66311a23d','생활',14891,'gs편의점 강남점','2025-09-23 12:05:42',12500),(6,22,35.0967654,128.8538622,34278,'CG-9ca85f66311a23d','생활',13784,'스타벅스 서울역점','2025-09-24 11:07:58',500);
/*!40000 ALTER TABLE `account_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alert`
--

DROP TABLE IF EXISTS `alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alert` (
  `alert_uuid` varchar(36) NOT NULL,
  `sender_uuid` char(36) NOT NULL,
  `receiver_uuid` char(36) NOT NULL,
  `content` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`alert_uuid`),
  KEY `fk_alert_sender` (`sender_uuid`),
  KEY `fk_alert_receiver` (`receiver_uuid`),
  CONSTRAINT `fk_alert_receiver` FOREIGN KEY (`receiver_uuid`) REFERENCES `user` (`user_uuid`),
  CONSTRAINT `fk_alert_sender` FOREIGN KEY (`sender_uuid`) REFERENCES `user` (`user_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alert`
--

LOCK TABLES `alert` WRITE;
/*!40000 ALTER TABLE `alert` DISABLE KEYS */;
INSERT INTO `alert` VALUES ('091b0a19-5671-4382-853f-91c7ed9deb7d','8341cbc6-0b00-4acf-b93e-6e4f4002c861','16e8c50d-43ff-4e1a-8077-17c13b108c5f','자녀 김싸피(이)가 등록되었습니다.','2025-09-26 09:23:01'),('cdcd4aad-b710-4f7a-bb87-cd87bc1fa398','3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e','eef34aa6-af0b-4fbd-af4d-72da087ba601','자녀 홍길동(이)가 등록되었습니다.','2025-09-23 16:51:36');
/*!40000 ALTER TABLE `alert` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auto_transfer`
--

DROP TABLE IF EXISTS `auto_transfer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auto_transfer` (
  `auto_transfer_uuid` char(36) NOT NULL,
  `relation_uuid` char(36) NOT NULL COMMENT 'parent_relation.relation_uuid 참조',
  `transfer_day` int NOT NULL COMMENT '매월 실행 일자 (1~31)',
  `transfer_time` time NOT NULL COMMENT '실행 시각 (HH:MM:SS)',
  `amount` bigint NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`auto_transfer_uuid`),
  KEY `FK_AUTO_TRANSFER_RELATION` (`relation_uuid`),
  KEY `idx_auto_transfer_time` (`transfer_time`),
  CONSTRAINT `FK_AUTO_TRANSFER_RELATION` FOREIGN KEY (`relation_uuid`) REFERENCES `parent_relation` (`relation_uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auto_transfer`
--

LOCK TABLES `auto_transfer` WRITE;
/*!40000 ALTER TABLE `auto_transfer` DISABLE KEYS */;
INSERT INTO `auto_transfer` VALUES ('03f1a848-112d-41b2-8f7d-8eb9c235882b','08e0b216-3888-472b-8f4e-e785e09a0cc6',1,'09:00:00',50000,'2025-09-24 16:58:18','2025-09-24 16:58:18'),('4d439fb9-8735-406b-be8b-bdf5b61eec14','9a8f752a-5c6c-4fa3-bb4a-d4cced5aab32',24,'15:00:00',50000,'2025-09-24 09:14:22','2025-09-26 09:07:42'),('724f2fd2-5ce4-4b3a-bc0f-c21dc8eb40ec','bcfa5269-b932-45ab-b694-1061bd2e81a6',1,'09:00:00',50000,'2025-09-23 01:57:40','2025-09-23 01:57:40');
/*!40000 ALTER TABLE `auto_transfer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `character_list`
--

DROP TABLE IF EXISTS `character_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `character_list` (
  `character_seq` bigint NOT NULL AUTO_INCREMENT,
  `character_name` varchar(20) NOT NULL,
  PRIMARY KEY (`character_seq`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `character_list`
--

LOCK TABLES `character_list` WRITE;
/*!40000 ALTER TABLE `character_list` DISABLE KEYS */;
INSERT INTO `character_list` VALUES (1,'키덕이'),(2,'어린이 키덕이'),(3,'운동선수 키덕이'),(4,'화가 키덕이');
/*!40000 ALTER TABLE `character_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_metadata`
--

DROP TABLE IF EXISTS `file_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_metadata` (
  `file_id` bigint NOT NULL AUTO_INCREMENT,
  `file_category` enum('IMAGES','MATERIALS','VIDEOS') NOT NULL,
  `related_type` enum('BOX','CHARACTER','SIGN','USER_PROFILE') NOT NULL,
  `related_uuid` varchar(36) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `sequence` int NOT NULL DEFAULT '1',
  `file_extension` varchar(20) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`file_id`),
  KEY `idx_file_related` (`related_uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_metadata`
--

LOCK TABLES `file_metadata` WRITE;
/*!40000 ALTER TABLE `file_metadata` DISABLE KEYS */;
INSERT INTO `file_metadata` VALUES (1,'IMAGES','USER_PROFILE','eef34aa6-af0b-4fbd-af4d-72da087ba601','U0UQOgi7NRuOXgn6LHSikIDTy1TWh688.png',1,'png','2025-09-22 09:51:04'),(2,'IMAGES','USER_PROFILE','3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e','다운로드.jpg',1,'jpg','2025-09-22 10:35:34'),(3,'IMAGES','BOX','c9fb16c3-5c6b-41b4-84b0-de94044bf915','피카추.jpg',1,'jpg','2025-09-22 16:22:20'),(4,'IMAGES','BOX','d872f116-c041-40a6-9fbd-de8290767947','ChatGPT Image 2025년 9월 18일 오후 10_32_09.png',1,'png','2025-09-22 16:23:42'),(5,'IMAGES','BOX','27b7c720-b890-4ca9-a826-2697579c0343','33.jpg',1,'jpg','2025-09-22 16:39:32'),(6,'IMAGES','BOX','1afb4ae8-c9d0-4c3c-9272-7814f233b9b0','33.jpg',1,'jpg','2025-09-22 17:06:05'),(8,'IMAGES','USER_PROFILE','d90afa6c-e93e-46cf-bbfe-9e9c20dde9b7','다운로드.jpg',1,'jpg','2025-09-22 20:38:47'),(9,'IMAGES','BOX','f529de15-3275-4750-b6f7-23775d829c33','scaled_33.jpg',1,'jpg','2025-09-23 11:42:30'),(10,'IMAGES','BOX','97372398-3c19-48af-8418-98c92d0da424','다운로드.jpg',1,'jpg','2025-09-24 15:25:30'),(11,'IMAGES','BOX','355eb5d4-3247-4c11-a62e-7e0dbc38e4b1','1000002978.jpg',1,'jpg','2025-09-24 16:57:44'),(12,'IMAGES','CHARACTER','1','키덕이.png',1,'png','2025-09-25 14:28:33'),(13,'IMAGES','CHARACTER','2','어린이키덕이.png',1,'png','2025-09-25 14:30:26'),(14,'IMAGES','CHARACTER','3','운동키덕이.png',1,'png','2025-09-25 14:30:50'),(15,'IMAGES','CHARACTER','4','화가키덕이.png',1,'png','2025-09-25 14:31:04');
/*!40000 ALTER TABLE `file_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifestyle_merchant`
--

DROP TABLE IF EXISTS `lifestyle_merchant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifestyle_merchant` (
  `merchant_id` bigint NOT NULL,
  `merchant_name` varchar(255) NOT NULL,
  `subcategory_id` bigint NOT NULL,
  PRIMARY KEY (`merchant_id`),
  KEY `idx_lm_subcategory` (`subcategory_id`),
  CONSTRAINT `fk_lm_subcategory` FOREIGN KEY (`subcategory_id`) REFERENCES `lifestyle_subcategory` (`subcategory_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifestyle_merchant`
--

LOCK TABLES `lifestyle_merchant` WRITE;
/*!40000 ALTER TABLE `lifestyle_merchant` DISABLE KEYS */;
INSERT INTO `lifestyle_merchant` VALUES (13784,'스타벅스 서울역점',2),(13785,'버거킹 신촌점',3),(13786,'24시 아이스크림 할인점',1),(14890,'cu편의점 서울역점',1),(14891,'gs편의점 강남점',1),(14892,'컴포즈 커피 서울역점',2),(14893,'이디야 커피 강남점',2),(14894,'봉구스 밥버거 강남점',3),(14895,'한솥 도시락 서울역점',3),(14896,'CU편의점 신호산단원룸점',1),(14897,'GS편의점 신호기적점',1),(14898,'컴포즈 커피 신호점',2),(14899,'이디야 커피 신호점',2),(14900,'한솥 도시락 신호점',3),(14901,'신전떡볶이 명지점',3),(14902,'싸피서점',4),(14903,'싸피문구',4),(14904,'CGV',5),(14905,'롯데시네마',5),(14906,'싸피아쿠아리움',5);
/*!40000 ALTER TABLE `lifestyle_merchant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifestyle_subcategory`
--

DROP TABLE IF EXISTS `lifestyle_subcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lifestyle_subcategory` (
  `subcategory_id` bigint NOT NULL AUTO_INCREMENT,
  `subcategory_name` varchar(50) NOT NULL,
  PRIMARY KEY (`subcategory_id`),
  UNIQUE KEY `uq_lms_name` (`subcategory_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifestyle_subcategory`
--

LOCK TABLES `lifestyle_subcategory` WRITE;
/*!40000 ALTER TABLE `lifestyle_subcategory` DISABLE KEYS */;
INSERT INTO `lifestyle_subcategory` VALUES (4,'문구/서점'),(5,'문화'),(3,'음식점'),(2,'카페'),(1,'편의점');
/*!40000 ALTER TABLE `lifestyle_subcategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loan`
--

DROP TABLE IF EXISTS `loan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan` (
  `loan_uuid` varchar(36) NOT NULL,
  `relation_uuid` char(36) NOT NULL,
  `loan_amount` bigint NOT NULL,
  `loan_interest` int NOT NULL DEFAULT '0',
  `loan_date` date DEFAULT NULL,
  `loan_due` date NOT NULL,
  `loan_content` varchar(1000) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_loaned` bit(1) NOT NULL,
  PRIMARY KEY (`loan_uuid`),
  KEY `fk_loan_relation_uuid` (`relation_uuid`),
  CONSTRAINT `fk_loan_relation_uuid` FOREIGN KEY (`relation_uuid`) REFERENCES `parent_relation` (`relation_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loan`
--

LOCK TABLES `loan` WRITE;
/*!40000 ALTER TABLE `loan` DISABLE KEYS */;
INSERT INTO `loan` VALUES ('6d99f220-927d-4b07-997b-23ea5dc5146b','bcfa5269-b932-45ab-b694-1061bd2e81a6',100000,0,NULL,'2025-12-25','test빌리기','2025-09-25 15:08:08','2025-09-25 15:08:08',_binary '\0');
/*!40000 ALTER TABLE `loan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mission`
--

DROP TABLE IF EXISTS `mission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mission` (
  `mission_uuid` varchar(36) NOT NULL,
  `relation_uuid` char(36) NOT NULL,
  `mission_title` varchar(20) NOT NULL,
  `mission_content` varchar(255) NOT NULL,
  `reward` bigint NOT NULL DEFAULT '0',
  `status` enum('FAILED','IN_PROGRESS','SUCCESS') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  PRIMARY KEY (`mission_uuid`),
  KEY `idx_mission_relation` (`relation_uuid`),
  CONSTRAINT `fk_mission_relation_uuid` FOREIGN KEY (`relation_uuid`) REFERENCES `parent_relation` (`relation_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mission`
--

LOCK TABLES `mission` WRITE;
/*!40000 ALTER TABLE `mission` DISABLE KEYS */;
INSERT INTO `mission` VALUES ('28973658-dd32-4510-bff9-1181d3f55a7d','bcfa5269-b932-45ab-b694-1061bd2e81a6','??','??',500000,'SUCCESS','2025-09-22 23:10:22',NULL,'2025-09-23 00:00:00'),('5868273a-4067-4c03-b773-18ed5e2fdd1d','bcfa5269-b932-45ab-b694-1061bd2e81a6','테스트','테스트입니다',10000,'SUCCESS','2025-09-22 11:34:46',NULL,'2025-09-25 00:00:00'),('66c783d0-416e-48cb-986b-086f34801765','9a8f752a-5c6c-4fa3-bb4a-d4cced5aab32','설거지하기?','저녁 설거지 부탁해~~!',1000,'IN_PROGRESS','2025-09-26 09:09:02',NULL,'2025-09-27 00:00:00'),('f65e0b4d-6f08-43ad-815b-0920b9e788ea','bcfa5269-b932-45ab-b694-1061bd2e81a6','지욱 테스트 미션 1','테스트 미션 1',1000,'IN_PROGRESS','2025-09-25 12:03:00',NULL,'2025-09-26 02:57:03'),('fda767b8-978c-467a-b628-714c85e7b5dd','bcfa5269-b932-45ab-b694-1061bd2e81a6','강태욱','123',1000,'SUCCESS','2025-09-24 17:00:47',NULL,'2025-09-27 00:00:00');
/*!40000 ALTER TABLE `mission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parent_relation`
--

DROP TABLE IF EXISTS `parent_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parent_relation` (
  `relation_uuid` char(36) NOT NULL,
  `parent_uuid` char(36) NOT NULL,
  `child_uuid` char(36) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`relation_uuid`),
  UNIQUE KEY `uq_child_unique` (`child_uuid`),
  KEY `idx_pc_parent` (`parent_uuid`),
  KEY `idx_pc_child` (`child_uuid`),
  CONSTRAINT `fk_pc_child_uuid` FOREIGN KEY (`child_uuid`) REFERENCES `user` (`user_uuid`),
  CONSTRAINT `fk_pc_parent_uuid` FOREIGN KEY (`parent_uuid`) REFERENCES `user` (`user_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parent_relation`
--

LOCK TABLES `parent_relation` WRITE;
/*!40000 ALTER TABLE `parent_relation` DISABLE KEYS */;
INSERT INTO `parent_relation` VALUES ('08e0b216-3888-472b-8f4e-e785e09a0cc6','5444880f-d9a9-4beb-999f-464e86763d63','705db7c9-bd93-4c70-b1ef-f42cc6fee15d','2025-09-23 10:27:25'),('24be3bb2-65c0-453c-b96a-bfe135e8ef1a','16e8c50d-43ff-4e1a-8077-17c13b108c5f','8341cbc6-0b00-4acf-b93e-6e4f4002c861','2025-09-26 09:23:01'),('9a8f752a-5c6c-4fa3-bb4a-d4cced5aab32','eef34aa6-af0b-4fbd-af4d-72da087ba601','3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e','2025-09-23 16:51:36'),('a68d30b0-d304-4b66-a308-a4a508e38893','5444880f-d9a9-4beb-999f-464e86763d63','2580df8b-66ed-4a1e-9693-0b326f89c09c','2025-09-25 00:12:27'),('bcfa5269-b932-45ab-b694-1061bd2e81a6','5444880f-d9a9-4beb-999f-464e86763d63','546e7ca0-5ae6-471c-84fe-81bea9ca67dc','2025-09-19 17:52:40');
/*!40000 ALTER TABLE `parent_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `save_box`
--

DROP TABLE IF EXISTS `save_box`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `save_box` (
  `box_uuid` char(36) NOT NULL,
  `children_uuid` char(36) NOT NULL,
  `box_name` varchar(255) NOT NULL,
  `saving` bigint NOT NULL DEFAULT '0',
  `remain` bigint NOT NULL DEFAULT '0',
  `target` bigint NOT NULL DEFAULT '0',
  `status` enum('IN_PROGRESS','SUCCESS') NOT NULL DEFAULT 'IN_PROGRESS',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`box_uuid`),
  KEY `idx_savebox_children` (`children_uuid`),
  CONSTRAINT `fk_savebox_child` FOREIGN KEY (`children_uuid`) REFERENCES `user` (`user_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `save_box`
--

LOCK TABLES `save_box` WRITE;
/*!40000 ALTER TABLE `save_box` DISABLE KEYS */;
INSERT INTO `save_box` VALUES ('97372398-3c19-48af-8418-98c92d0da424','3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e','컴퓨터',3000,6000,300000,'IN_PROGRESS','2025-09-24 15:25:30','2025-09-24 15:43:01');
/*!40000 ALTER TABLE `save_box` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `save_box_item`
--

DROP TABLE IF EXISTS `save_box_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `save_box_item` (
  `save_box_item_seq` bigint NOT NULL AUTO_INCREMENT,
  `box_uuid` char(36) NOT NULL,
  `box_pay_name` varchar(20) NOT NULL COMMENT '정기 적금/추가적금 이름',
  `box_transfer_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `box_amount` bigint NOT NULL COMMENT '금액(원)',
  PRIMARY KEY (`save_box_item_seq`),
  KEY `idx_saveboxitem_box` (`box_uuid`),
  CONSTRAINT `fk_saveboxitem_box` FOREIGN KEY (`box_uuid`) REFERENCES `save_box` (`box_uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `save_box_item`
--

LOCK TABLES `save_box_item` WRITE;
/*!40000 ALTER TABLE `save_box_item` DISABLE KEYS */;
INSERT INTO `save_box_item` VALUES (1,'97372398-3c19-48af-8418-98c92d0da424','정기적금','2025-09-24 15:29:01',3000),(2,'97372398-3c19-48af-8418-98c92d0da424','정기적금','2025-09-24 15:43:01',3000);
/*!40000 ALTER TABLE `save_box_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `user_uuid` char(36) NOT NULL,
  `name` varchar(100) NOT NULL,
  `birthdate` date DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `role` enum('CHILD','PARENT') NOT NULL,
  `provider` enum('GOOGLE','KAKAO') DEFAULT NULL,
  `provider_id` varbinary(512) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `ssafy_user_key` varbinary(512) DEFAULT NULL,
  PRIMARY KEY (`user_uuid`),
  UNIQUE KEY `uq_user_email` (`email`),
  UNIQUE KEY `uq_user_provider` (`provider`,`provider_id`),
  UNIQUE KEY `uq_user_ssafy_user_key` (`ssafy_user_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES ('16e8c50d-43ff-4e1a-8077-17c13b108c5f','김아빠','1996-11-29','ssafy2727@gmail.com','PARENT','GOOGLE',_binary 'J.\'��ƴ��:B\�*��t��\��\�\'��q���\'�\�t��[l\'b','2025-09-25 15:38:16','2025-09-25 17:58:36',NULL,_binary 'J.\'�(y\�\03�W�pۄ���JB9I\�8�\'h2�\\:�ou�����#\�+\��A&�\�'),('2580df8b-66ed-4a1e-9693-0b326f89c09c','각태욱','2025-09-07','twkang1101@gmail.com','CHILD','GOOGLE',_binary 'J.\'�H��*兪��\'\���p�rKP��\���q�y\�Ceos�\�','2025-09-23 12:36:07','2025-09-23 12:36:07',NULL,_binary 'J.\'�����gQq椋Q\ZM%`#J[\�\�\���O�@�\�D��i\�J`}�\�n\�E:Xv�'),('3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e','홍길동','2010-01-01','syb031789@gmail.com','CHILD','GOOGLE',_binary 'J.\'�X\�\�\�.B\�E�JI�GXǽD\�\Z^\�\�j���҉\�э','2025-09-22 10:35:34','2025-09-22 10:35:34',NULL,_binary 'J.\'�Et�\�\�_	�	pW|\�\���\�\�7L��b�OI\�\�N\�U��}ߝ\�\'�a\�,\�='),('5444880f-d9a9-4beb-999f-464e86763d63','강태욱','2021-01-05','sunshinemoongit@gmail.com','PARENT','GOOGLE',_binary 'J.\'��?��?-5#\�N\�\0\��\�\�!=\�Y�gN\��\�Y��','2025-09-18 10:54:44','2025-09-22 15:20:28',NULL,_binary 'J.\'�s\\�\n\�\"\�,��`�E\�@\"�?*�7K��gw1[\�YW��t�3`\�:֣�\�.'),('546e7ca0-5ae6-471c-84fe-81bea9ca67dc','leejiun','2022-05-02','leejiwoo0126@gmail.com','CHILD','GOOGLE',_binary 'J.\'�\0֞\0���=\Z�2^\�\�x�\�0\�%\�y\�]\��D��浵K','2025-09-18 12:01:41','2025-09-22 10:05:16',NULL,_binary 'J.\'�6|3ύwcf��\�!\�=\��{�{�!)(�a٩B��cW�\�E/	�h�)B>��'),('5871946a-3054-469a-9bf0-e9aa05935dc8','강강강','2019-09-24','taewookkang1101@gmail.com','CHILD','GOOGLE',_binary 'J.\'����$@1L\�>֍�E���\�\Z��63hd2\�`uK~^��^R','2025-09-24 15:33:50','2025-09-24 15:33:50',NULL,_binary 'J.\'�C\�t��B~\�\��Ȋ���x|\�!!�C\�]23֤h\\\�B^]t[2,�\�\�\na�\�'),('705db7c9-bd93-4c70-b1ef-f42cc6fee15d','윤지욱','2025-07-01','jiuk202@gmail.com','CHILD','GOOGLE',_binary 'J.\'����\�;ֆ�׺\�\�%[�w�o\nJ\�\���i��S\�=�\��Ws','2025-09-19 09:42:40','2025-09-22 10:05:04',NULL,_binary 'J.\'��6cZrʩ\�jc\�ܨMs7\�f|�ڥW�5���l�{B+�\',X�p�HtBL/\�'),('8209e1e7-8f36-49a8-a3e3-ddf83a87f8e3','장준혁','2000-11-07','wnsgur001107@gmail.com','PARENT','GOOGLE',_binary 'J.\'��5\'&�7^\�\'\�0�h���\�\�.r\��8�2\�n)(*','2025-09-24 10:45:43','2025-09-24 10:45:43',NULL,_binary 'J.\'�;�\��8�,��\�\�,\�!� Ո�� �3�G�MKj\�\�ϐ8\�&`��ּ\Z9 O'),('8341cbc6-0b00-4acf-b93e-6e4f4002c861','김싸피','2015-09-26','ssafychild1234@gmail.com','CHILD','GOOGLE',_binary 'J.\'�g���4\�а�\�\�|\�.V��%���S���\�\�)�\�����','2025-09-26 09:17:31','2025-09-26 09:17:31',NULL,_binary 'J.\'�Ʈ�?C�n�ހ]\�\�\�4U&\��t\�NXQ�\��o?=ӡ\�\�U)\�\����9K\�x'),('bb452832-1fa9-4792-bb77-9bbd4b63678b','wl202wl',NULL,'wl202wl@naver.com','CHILD',NULL,NULL,'2025-09-23 15:08:57','2025-09-23 15:08:57',NULL,_binary 'J.\'�9#k�\�ɚ�\nk�hãnF\�\�\�\��6ՁB�mF�\�re${�\�ڵ�GH\��	\�(e'),('cbde2a9a-394f-49fe-a007-9ad3402510ac','테스트','2008-09-26','moonjoi1101@gmail.com','CHILD','GOOGLE',_binary 'J.\'�l;��St��6�+\�(�&�M�R>{\���\�\�\�E�\�','2025-09-26 09:11:55','2025-09-26 09:11:55',NULL,_binary 'J.\'�\���M:���ζ:��;-\�F}�\�\���h�\0�\��S�#H�r�\�\�\�Q\�Y�(p'),('d90afa6c-e93e-46cf-bbfe-9e9c20dde9b7','유빈','2010-03-11','syb0317@pusan.ac.kr','CHILD','GOOGLE',_binary 'J.\'��K\�\�?�y�(��}�+�$f\�5�\\H�*��ȓ���','2025-09-22 20:38:47','2025-09-22 20:38:47',NULL,_binary 'J.\'�\��\�\�݁|\'.dր�k�\�m\�0+���)K#���6!7@�T\�\�����4���s��'),('eef34aa6-af0b-4fbd-af4d-72da087ba601','신유빈','2000-03-17','syb0317timo12@gmail.com','PARENT','GOOGLE',_binary 'J.\'�\�\�\�j�\�X�Z\���^6G�u���}z<\�ģ\�\�\�','2025-09-17 09:26:24','2025-09-22 09:28:26',NULL,_binary 'J.\'���<p?\�\�Q�\�3K��\�i�\��\��N�J��mƳ\"�(G:�.���:�\�J�\�h�w=��');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_character`
--

DROP TABLE IF EXISTS `user_character`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_character` (
  `user_character_seq` int NOT NULL AUTO_INCREMENT,
  `user_uuid` char(36) NOT NULL,
  `character_seq` bigint NOT NULL,
  `experience` int NOT NULL DEFAULT '0',
  `level` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`user_character_seq`),
  KEY `fk_character_list` (`character_seq`),
  KEY `fk_character_user` (`user_uuid`),
  CONSTRAINT `fk_character_list` FOREIGN KEY (`character_seq`) REFERENCES `character_list` (`character_seq`),
  CONSTRAINT `fk_character_user` FOREIGN KEY (`user_uuid`) REFERENCES `user` (`user_uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_character`
--

LOCK TABLES `user_character` WRITE;
/*!40000 ALTER TABLE `user_character` DISABLE KEYS */;
INSERT INTO `user_character` VALUES (1,'3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e',1,0,1),(2,'d90afa6c-e93e-46cf-bbfe-9e9c20dde9b7',1,0,1),(3,'2580df8b-66ed-4a1e-9693-0b326f89c09c',1,0,1),(4,'8209e1e7-8f36-49a8-a3e3-ddf83a87f8e3',1,0,1),(5,'5871946a-3054-469a-9bf0-e9aa05935dc8',1,0,1),(6,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc',1,316,1),(7,'16e8c50d-43ff-4e1a-8077-17c13b108c5f',1,0,1),(8,'cbde2a9a-394f-49fe-a007-9ad3402510ac',1,0,1),(9,'8341cbc6-0b00-4acf-b93e-6e4f4002c861',1,0,1);
/*!40000 ALTER TABLE `user_character` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_device_token`
--

DROP TABLE IF EXISTS `user_device_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_device_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_uuid` varchar(50) NOT NULL,
  `token` varchar(512) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_token` (`token`),
  KEY `idx_user` (`user_uuid`),
  CONSTRAINT `fk_udt_user` FOREIGN KEY (`user_uuid`) REFERENCES `user` (`user_uuid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_device_token`
--

LOCK TABLES `user_device_token` WRITE;
/*!40000 ALTER TABLE `user_device_token` DISABLE KEYS */;
INSERT INTO `user_device_token` VALUES (1,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','ckf_M4KaSreIQKlf0NB2U-:APA91bEiz6J3m6yhWSBxx8py89sc5Vx95mjc3z0-NSV5beB3KkMkWJ0soAuDh8czXhm_o0lbmIqE8F4ww1yq4Nw62b01a1dj2m-1JlBuqtZNhfg_P-fOB0o','2025-09-21 15:06:11','2025-09-25 11:53:50'),(2,'2580df8b-66ed-4a1e-9693-0b326f89c09c','dCwPoHh-R5OVdVwhCf-9Va:APA91bE9BVNhsFIbI90gj8N6Ny4Vw1bws1_K8GeOYMMltizRSLAu2NeHAu5ruIAwwMIsDGVjfwlWmFIleJGqeHyLWHAqWPz2ZBkJZAUxFOBt4pRLIGZz4EA','2025-09-21 15:51:11','2025-09-25 00:46:10'),(3,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','dh33EZHWQeycwegxFnV1re:APA91bEERi5EiAAA_xju4WxKhVMG8K2PsT6e4qReCAddxoHRoEv4biwvDr0ggUWll3UMNZOGWUvM4UVAxVyPovBpRzDp3kV2x6GtspYxyIdxAVLJ1uZn944','2025-09-22 08:58:51','2025-09-22 08:58:51'),(4,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','cb1WNwAuSLakdNVBw_k9Z7:APA91bFKpgCwzuWegsH0iox3dyUrMKDDtTRV7SC8wZSTM7Iam9zlsYmQlS35Q6ROJkap613aMJPQWv4ph_0AOZz4MDaE3KcnTpcaamR5YrHqXZdU0iVmyYk','2025-09-22 10:09:03','2025-09-22 10:09:03'),(5,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','e_ZWPmzJR_2DaMzccJcyHn:APA91bFJ5rFoR8Qi3YALU0TC5xiKe3oUpDDrbVyCmTfo6dDWUgKdFpVZhjsKmEhaKEWhzADxseJ2gCbvGIJg3hhrYBNQa7r0okIsQlT5ZV6Q7SLdQFWU5xQ','2025-09-22 11:21:46','2025-09-22 11:21:46'),(6,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','d-PKLHs2RoKjcOMNrsm8aD:APA91bGjTgj2mk0bSGSRy7fMXd-0flNF37rXt56PeZMzs_u4TR3iNcyg7gmX4COkSj8GwTir8boNBvCQwkO7panJldaxuO9luIZ1BxgXqcMtDfJ-fLm2w14','2025-09-22 11:31:10','2025-09-22 11:31:10'),(7,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','euPKy9VxR8S2dsDyWGGSHp:APA91bGUCuQkSYJ32C8J8Vrssaw_IP5comVexgS4BJ03-ezUAiurYzzWNhkLO8Dq9lRzGajI1I-89HobThj1VJ3JfkWmWtDTeGEK4Nubm6usYLuNvZhzlB0','2025-09-22 11:33:59','2025-09-22 11:33:59'),(8,'3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e','ezsH6f5qQ4StxhCFV1vDeD:APA91bFgAUy3k2jDSMnjvmgNUB-uP1Pw9sGGj_f6Yd_EoinHr2JNw-lyPBy8WV9lVLHNiJHyAsA9pcRQCAw5ahkg42M897SiTrBh6N8OH5GmifNvcSi43rY','2025-09-22 14:26:57','2025-09-22 14:26:57'),(9,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','coZ6A74JTTC3UrEpjqZqdo:APA91bHWuzbNTZzMHcNcnoYcO9-ps9HTtmShA-1-F3lwMpPTI-GnbY1QS0ediH11qyhDVQFt8mO2pK1V0j0ohBO2bwg2hIr9_vnI2jgz8yYYFfY2aMQSCAg','2025-09-22 20:02:08','2025-09-22 20:02:08'),(10,'546e7ca0-5ae6-471c-84fe-81bea9ca67dc','e9qpRuwQTtKiAMAcoI88DX:APA91bGN2HRPG3LBJmrV4l8IDgo44oQ0_ZSnYxBGaZ_jq3xmQF7diB-upPQcEWmb_pX_HyZi1r9zNNDucV9w2NRkVZNnENclWJpB_LZz7ac4Jx4ef0M2KtU','2025-09-23 10:25:42','2025-09-25 09:57:44'),(11,'8209e1e7-8f36-49a8-a3e3-ddf83a87f8e3','eArJVfMsQI-OoQoLZXL3gy:APA91bFsWvGuX9rglQ6DQsAkrcPOTJWSxeTFSXSTHZzpw3r2vNTj0VBoH-eNq7nrhUraW2O1JPdNfClTOuB0Of0LliOL8R83EI5XvDfUICHh14B_yI36Hh8','2025-09-24 11:07:12','2025-09-24 11:07:12'),(12,'8209e1e7-8f36-49a8-a3e3-ddf83a87f8e3','f2JlHe5HROy_CESONg4HZy:APA91bGVeDo_mEMUnZlNy5c2bSVb0fTZllnVHBuz0icdz_hWULXEsDtzGObEURTNZhDhCjIbn2aVk2FoY8AWstKOSOoKwwFb7cposCPw1T4c1FGxAl9S9TY','2025-09-24 11:11:08','2025-09-24 11:11:08'),(14,'5444880f-d9a9-4beb-999f-464e86763d63','drpzNSKAS8-b7lEo85l-0L:APA91bF5w_z-I0T4rQHOn1Y6IkD05ToZ6x5Nv_uQEep24lTkKF0avEv3VZ-24b3xdK1k2kxz5QquG5NkqXuoW9YlWXyyxVq2dQnh20V62WL4YCEBQfVKXis','2025-09-25 12:37:03','2025-09-25 15:54:59'),(15,'5444880f-d9a9-4beb-999f-464e86763d63','cVSMKq47Q2mpuT367lokZe:APA91bEQXmnJ3qZFd9tqOMg-XwL0bBkkD3kXgXc4oIWywbu0WFpo_aAZrHcjl3mcfj6zVyKOKWjKtoMVce2qKzjikdkxhamPj7mSNO3QP21vLPLmL5Fv6hI','2025-09-25 17:24:58','2025-09-25 17:24:58'),(16,'5444880f-d9a9-4beb-999f-464e86763d63','fP7kn830Qo62rRMWXJ8j0N:APA91bFWv6MMH_aPp-0emi6x-NefPC9KGemuES7VBEi4SUQ22IetmK7fcLsToyn_PG36PFq7gngUKBcHLqcpRazEX8nvUI3YfNVfVHSEG0piKZS8zLVuPGA','2025-09-25 17:31:22','2025-09-25 17:31:22'),(17,'5444880f-d9a9-4beb-999f-464e86763d63','fus72IURRYy77ROE4Za5VB:APA91bFyD-HFfU84Ub9sIlsMfXaV7dq2xj_G8wfZh_kpu5Zq5puaDOYwnX4TnvkRibdMIUGxD8ACHYqSE_pXeydtDSXSN2Z2GDdgnQAbx0daLVoMZA08qNM','2025-09-25 18:01:44','2025-09-25 18:01:44'),(18,'16e8c50d-43ff-4e1a-8077-17c13b108c5f','ckx6mS-0SoGSL5R3NYjhYK:APA91bFnZO_0xwLOt8IOj5DuTW4RhZ2UnC-nJeFPUBVobzKo8WxGy9Q4Eyj78RMfjL9A_6EOkY-4d-RPSJOerdYejKpFfOtuaXdvlZhMFA7uqxn4weBAD_4','2025-09-26 08:55:39','2025-09-26 08:55:39'),(19,'3c4dbc9c-5d22-46fd-af91-df1a0fb31a1e','egi3ipi1RpWfLAkfgV3pEX:APA91bFi-JKaI9JCwIdpzHdW9tM5kQp0pP0RzdXFRr1qyj2dquFYkaQRGZSHjlmrA4D5xrykKcuJH62YL9nWNZ098_xL6VaRVHfw62N5MPBxQ1qTfMOoEIY','2025-09-26 09:06:56','2025-09-26 09:11:12');
/*!40000 ALTER TABLE `user_device_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'kdkd'
--

--
-- Dumping routines for database 'kdkd'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-26  9:25:11
