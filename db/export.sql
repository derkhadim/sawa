CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar NOT NULL, "phone" varchar NOT NULL, "password_digest" varchar NOT NULL, "first_name" varchar NOT NULL, "last_name" varchar NOT NULL, "role" varchar DEFAULT 'tenant' NOT NULL, "agency_id" integer, "building_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "profile_photo" varchar, "cover_photo" varchar, "rating" integer DEFAULT NULL, CONSTRAINT "fk_rails_627daf9bbe"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
, CONSTRAINT "fk_rails_6a7f33726f"
FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id")
);
CREATE TABLE sqlite_sequence(name,seq);
CREATE INDEX "index_users_on_agency_id" ON "users" ("agency_id");
CREATE INDEX "index_users_on_building_id" ON "users" ("building_id");
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_phone" ON "users" ("phone");
CREATE TABLE IF NOT EXISTS "agencies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "address" varchar, "phone" varchar, "email" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "owners" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar NOT NULL, "last_name" varchar NOT NULL, "phone" varchar, "email" varchar, "agency_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_1f35333df5"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
CREATE INDEX "index_owners_on_agency_id" ON "owners" ("agency_id");
CREATE TABLE IF NOT EXISTS "buildings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "address" varchar NOT NULL, "neighborhood" varchar, "commune" varchar, "latitude" decimal(10,7), "longitude" decimal(10,7), "owner_id" integer NOT NULL, "agency_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "photo" varchar, CONSTRAINT "fk_rails_b8dfe07c9e"
FOREIGN KEY ("owner_id")
  REFERENCES "owners" ("id")
, CONSTRAINT "fk_rails_235930fc52"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
CREATE INDEX "index_buildings_on_owner_id" ON "buildings" ("owner_id");
CREATE INDEX "index_buildings_on_agency_id" ON "buildings" ("agency_id");
CREATE TABLE IF NOT EXISTS "apartments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "number" varchar NOT NULL, "floor" integer, "rent_amount" decimal(10,2) NOT NULL, "status" varchar DEFAULT 'free' NOT NULL, "building_id" integer NOT NULL, "tenant_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "photos" text, "visible" boolean DEFAULT 0 NOT NULL, CONSTRAINT "fk_rails_9c46e85795"
FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id")
, CONSTRAINT "fk_rails_9d72b77c1a"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_apartments_on_building_id" ON "apartments" ("building_id");
CREATE INDEX "index_apartments_on_tenant_id" ON "apartments" ("tenant_id");
CREATE UNIQUE INDEX "index_apartments_on_building_id_and_number" ON "apartments" ("building_id", "number");
CREATE TABLE IF NOT EXISTS "payments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "amount" decimal(10,2) NOT NULL, "paid_at" date, "due_date" date NOT NULL, "status" varchar DEFAULT 'pending' NOT NULL, "month" integer NOT NULL, "year" integer NOT NULL, "reference" varchar, "apartment_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "proof" varchar, "payment_method" varchar DEFAULT NULL, CONSTRAINT "fk_rails_73a62ad939"
FOREIGN KEY ("apartment_id")
  REFERENCES "apartments" ("id")
, CONSTRAINT "fk_rails_37fe743ccd"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_payments_on_apartment_id" ON "payments" ("apartment_id");
CREATE INDEX "index_payments_on_tenant_id" ON "payments" ("tenant_id");
CREATE UNIQUE INDEX "index_payments_on_apartment_id_and_month_and_year" ON "payments" ("apartment_id", "month", "year");
CREATE TABLE IF NOT EXISTS "publications" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "content" text NOT NULL, "building_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "likes_count" integer DEFAULT 0 NOT NULL, "comments_count" integer DEFAULT 0 NOT NULL, CONSTRAINT "fk_rails_8d10004933"
FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id")
, CONSTRAINT "fk_rails_cf498aa521"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_publications_on_building_id" ON "publications" ("building_id");
CREATE INDEX "index_publications_on_tenant_id" ON "publications" ("tenant_id");
CREATE TABLE IF NOT EXISTS "move_out_notices" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "move_out_date" date NOT NULL, "apartment_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_538f86e910"
FOREIGN KEY ("apartment_id")
  REFERENCES "apartments" ("id")
, CONSTRAINT "fk_rails_746c66b351"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_move_out_notices_on_apartment_id" ON "move_out_notices" ("apartment_id");
CREATE INDEX "index_move_out_notices_on_tenant_id" ON "move_out_notices" ("tenant_id");
CREATE TABLE IF NOT EXISTS "likes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "publication_id" integer NOT NULL, "user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c5db1cc33f"
FOREIGN KEY ("publication_id")
  REFERENCES "publications" ("id")
, CONSTRAINT "fk_rails_1e09b5dabf"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_likes_on_publication_id" ON "likes" ("publication_id");
CREATE INDEX "index_likes_on_user_id" ON "likes" ("user_id");
CREATE UNIQUE INDEX "index_likes_on_publication_id_and_user_id" ON "likes" ("publication_id", "user_id");
CREATE TABLE IF NOT EXISTS "comments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "publication_id" integer NOT NULL, "user_id" integer NOT NULL, "content" text NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_6be1db031f"
FOREIGN KEY ("publication_id")
  REFERENCES "publications" ("id")
, CONSTRAINT "fk_rails_03de2dc08c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_comments_on_publication_id" ON "comments" ("publication_id");
CREATE INDEX "index_comments_on_user_id" ON "comments" ("user_id");
CREATE TABLE IF NOT EXISTS "providers" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar NOT NULL, "last_name" varchar NOT NULL, "phone" varchar NOT NULL, "trade" varchar NOT NULL, "agency_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c8e9781280"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
CREATE INDEX "index_providers_on_agency_id" ON "providers" ("agency_id");
CREATE TABLE IF NOT EXISTS "incidents" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar NOT NULL, "description" text NOT NULL, "status" varchar DEFAULT 'open' NOT NULL, "apartment_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "provider_id" integer, CONSTRAINT "fk_rails_6e72ca0e49"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_a51d50c7bc"
FOREIGN KEY ("apartment_id")
  REFERENCES "apartments" ("id")
, CONSTRAINT "fk_rails_aee7a62715"
FOREIGN KEY ("provider_id")
  REFERENCES "providers" ("id")
);
CREATE INDEX "index_incidents_on_apartment_id" ON "incidents" ("apartment_id");
CREATE INDEX "index_incidents_on_tenant_id" ON "incidents" ("tenant_id");
CREATE INDEX "index_incidents_on_provider_id" ON "incidents" ("provider_id");
CREATE TABLE IF NOT EXISTS "permissions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "resource" varchar NOT NULL, "action" varchar NOT NULL, "description" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_permissions_on_resource_and_action" ON "permissions" ("resource", "action");
CREATE TABLE IF NOT EXISTS "roles" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "agency_id" integer, "description" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_1fc3d10048"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
CREATE INDEX "index_roles_on_agency_id" ON "roles" ("agency_id");
CREATE UNIQUE INDEX "index_roles_on_name_and_agency_id" ON "roles" ("name", "agency_id");
CREATE TABLE IF NOT EXISTS "role_permissions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "role_id" integer NOT NULL, "permission_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_60126080bd"
FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id")
, CONSTRAINT "fk_rails_439e640a3f"
FOREIGN KEY ("permission_id")
  REFERENCES "permissions" ("id")
);
CREATE INDEX "index_role_permissions_on_role_id" ON "role_permissions" ("role_id");
CREATE INDEX "index_role_permissions_on_permission_id" ON "role_permissions" ("permission_id");
CREATE UNIQUE INDEX "index_role_permissions_on_role_id_and_permission_id" ON "role_permissions" ("role_id", "permission_id");
CREATE TABLE IF NOT EXISTS "user_roles" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "role_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_318345354e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_3369e0d5fc"
FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id")
);
CREATE INDEX "index_user_roles_on_user_id" ON "user_roles" ("user_id");
CREATE INDEX "index_user_roles_on_role_id" ON "user_roles" ("role_id");
CREATE UNIQUE INDEX "index_user_roles_on_user_id_and_role_id" ON "user_roles" ("user_id", "role_id");
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
INSERT INTO schema_migrations VALUES('20260101000001');
INSERT INTO schema_migrations VALUES('20260101000002');
INSERT INTO schema_migrations VALUES('20260101000003');
INSERT INTO schema_migrations VALUES('20260101000004');
INSERT INTO schema_migrations VALUES('20260101000005');
INSERT INTO schema_migrations VALUES('20260101000006');
INSERT INTO schema_migrations VALUES('20260101000007');
INSERT INTO schema_migrations VALUES('20260101000008');
INSERT INTO schema_migrations VALUES('20260101000009');
INSERT INTO schema_migrations VALUES('20260618200003');
INSERT INTO schema_migrations VALUES('20260618221657');
INSERT INTO schema_migrations VALUES('20260618221658');
INSERT INTO schema_migrations VALUES('20260618221722');
INSERT INTO schema_migrations VALUES('20260620062702');
INSERT INTO schema_migrations VALUES('20260620130000');
INSERT INTO schema_migrations VALUES('20260620130001');
INSERT INTO schema_migrations VALUES('20260620130002');
INSERT INTO schema_migrations VALUES('20260620140000');
INSERT INTO schema_migrations VALUES('20260620150000');
INSERT INTO schema_migrations VALUES('20260620160000');
INSERT INTO schema_migrations VALUES('20260620170000');
INSERT INTO schema_migrations VALUES('20260620180000');
INSERT INTO schema_migrations VALUES('20260620190000');
INSERT INTO schema_migrations VALUES('20260620200000');
INSERT INTO schema_migrations VALUES('20260622000000');
INSERT INTO schema_migrations VALUES('20260622000001');
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
INSERT INTO ar_internal_metadata VALUES('environment','development','2026-06-18 15:58:17.980639','2026-06-18 15:58:17.980641');
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar NOT NULL, "phone" varchar NOT NULL, "password_digest" varchar NOT NULL, "first_name" varchar NOT NULL, "last_name" varchar NOT NULL, "role" varchar DEFAULT 'tenant' NOT NULL, "agency_id" integer, "building_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "profile_photo" varchar, "cover_photo" varchar, "rating" integer DEFAULT NULL, CONSTRAINT "fk_rails_627daf9bbe"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
, CONSTRAINT "fk_rails_6a7f33726f"
FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id")
);
INSERT INTO users VALUES(151,'admin@loca.com','+221770000003','$2a$12$ipGZRq.z8ZsHafI13nYMTuGMAHXmVTf9wrVi/7oJEI/giKf9ziaHm','Super','Admin','super_admin',NULL,NULL,'2026-06-18 21:47:32.897717','2026-06-18 21:47:32.897717',NULL,NULL,NULL);
INSERT INTO users VALUES(152,'agent@loca.com','+221770000006','$2a$12$OkUcI9kG0jW8JCV4KNuk1edCxa2B3Ey/NdRszXIEtdLECvbj5NTHW','Agent','Principal','agence',12,NULL,'2026-06-18 21:47:33.124308','2026-06-18 21:47:33.124308',NULL,NULL,NULL);
INSERT INTO users VALUES(153,'agent2@loca.com','+221770000007','$2a$12$1KrqQJQb/9pRpOhw0Qz2ieCTSFxFjlwpOcOdq97q2ibTtDddSnSaO','Agent','Sene','agence',13,NULL,'2026-06-18 21:47:33.327255','2026-06-18 21:47:33.327255',NULL,NULL,NULL);
INSERT INTO users VALUES(154,'tenant1@loca.com','+221770000009','$2a$12$BiFmdOGqN4iHGOdz4HRcUuOW4jzKPdVqtCPzLq9zA6uyb141FAjza','Carloman','Barre','tenant',NULL,11,'2026-06-18 21:47:33.663361','2026-06-22 08:49:53.117863',NULL,NULL,1);
INSERT INTO users VALUES(155,'tenant2@loca.com','+221770000010','$2a$12$3P1SwpgsAdrBNnPPktnl3OviG8lzgSVDtGgXgP4V10sE1f4/i5dHe','Dimitri','Jean','tenant',NULL,11,'2026-06-18 21:47:33.874330','2026-06-22 08:50:53.914390',NULL,NULL,2);
INSERT INTO users VALUES(156,'tenant3@loca.com','+221770000011','$2a$12$639sS.DAqn2n7sr9HhyZKeunRwgadTe1pFQRzTnTfhEXBzsN7mWhS','Basilisse','Robin','tenant',NULL,11,'2026-06-18 21:47:34.088637','2026-06-22 09:49:42.694225',NULL,NULL,2);
INSERT INTO users VALUES(157,'tenant4@loca.com','+221770000012','$2a$12$4XaW9yzsebstBIGcY303CeNkztZbPYYQTNGzOJVDT5RLQavWBxU5y','Marius','Leroy','tenant',NULL,11,'2026-06-18 21:47:34.304355','2026-06-22 09:53:22.901147',NULL,NULL,2);
INSERT INTO users VALUES(158,'tenant5@loca.com','+221770000013','$2a$12$1GFJtHqZzq6HPNji1HNWj.FWL1m0xHHS2WdrdNPM2w0M9tyGxjvPm','Gautier','Lacroix','tenant',NULL,11,'2026-06-18 21:47:34.516055','2026-06-22 08:49:53.128386',NULL,NULL,1);
INSERT INTO users VALUES(159,'tenant6@loca.com','+221770000014','$2a$12$xQJknmTbslg4sIqBgNkVuOo/OFEuFxBIJJbnDRUV1pwuqXl/tCJzK','Agapet','Baron','tenant',NULL,11,'2026-06-18 21:47:34.732992','2026-06-22 08:49:53.131001',NULL,NULL,1);
INSERT INTO users VALUES(160,'tenant7@loca.com','+221770000015','$2a$12$nviVMqPHCVC9c7fdS3lI8.TOlTgOm0hWJA4TDsjoda.lf0Zs5pJ8i','Flavien','Méunier','tenant',NULL,11,'2026-06-18 21:47:34.939093','2026-06-22 08:49:53.133582',NULL,NULL,1);
INSERT INTO users VALUES(161,'tenant8@loca.com','+221770000016','$2a$12$xIfQteaqG59N/LTNAZ292uDRjq7SpNsSFosackgngSHBs2UarMqM2','Mélisande','Guillaume','tenant',NULL,11,'2026-06-18 21:47:35.147106','2026-06-22 08:49:53.136156',NULL,NULL,1);
INSERT INTO users VALUES(162,'tenant9@loca.com','+221770000017','$2a$12$sVRU98P.ATzAR4K0CBNDm.Hbm06b25BK4ErythLBdqxN.nAXH.Kni','Avoye','Fernandez','tenant',NULL,11,'2026-06-18 21:47:35.373398','2026-06-22 08:49:53.138705',NULL,NULL,1);
INSERT INTO users VALUES(163,'tenant10@loca.com','+221770000018','$2a$12$n2KlIJpTK5.TlM60.yw1FuOjdyfLUpAu5lulVodVY9iqAS5VT0eyS','Aline','Leclercq','tenant',NULL,11,'2026-06-18 21:47:35.577731','2026-06-22 08:49:53.141271',NULL,NULL,1);
INSERT INTO users VALUES(164,'tenant11@loca.com','+221770000019','$2a$12$lf3w6XsKT6xC7gPCJcE7qeFVBaSN8WrX5TIXLB6RNelOhNyHwFBme','Mathurin','Lopez','tenant',NULL,11,'2026-06-18 21:47:35.781008','2026-06-22 08:49:53.143851',NULL,NULL,1);
INSERT INTO users VALUES(165,'tenant12@loca.com','+221770000020','$2a$12$rEdg17ItA1hXI31NQyOb7..UKHUs3Ok/L6WKQmjcSekffXmhGJD6y','Adrehilde','Bourgeois','tenant',NULL,11,'2026-06-18 21:47:36.006109','2026-06-22 08:49:53.155447',NULL,NULL,1);
INSERT INTO users VALUES(166,'tenant13@loca.com','+221770000021','$2a$12$WqI2S9X9iWpARsiYtXgpM.L7QokeIAS06Z/pIGiwZaYhdCD27px76','Bérangère','Mathieu','tenant',NULL,11,'2026-06-18 21:47:36.222693','2026-06-22 08:49:53.158430',NULL,NULL,1);
INSERT INTO users VALUES(167,'tenant14@loca.com','+221770000022','$2a$12$nlY.rQguqW/9No9/ZSUqV.kRWtr5x.EJ.nyOzsm5T9TXQg/1x66Zu','Yseult','Richard','tenant',NULL,11,'2026-06-18 21:47:36.439792','2026-06-22 08:49:53.161211',NULL,NULL,1);
INSERT INTO users VALUES(168,'tenant15@loca.com','+221770000023','$2a$12$9p69bLpR40eBFGe5WAZr4OfHpBXTA2sgEQ54wTq/6pJ6qY9xbQqbC','Alban','Le Gall','tenant',NULL,11,'2026-06-18 21:47:36.659740','2026-06-22 08:49:53.164064',NULL,NULL,1);
INSERT INTO users VALUES(169,'tenant16@loca.com','+221770000024','$2a$12$r0J/CnP/6g09Qlpum8QtEOT3.D.tokiyZsxjyQpzuThCpcVkyT.N.','Mence','Brunet','tenant',NULL,11,'2026-06-18 21:47:36.860181','2026-06-22 08:49:53.167070',NULL,NULL,1);
INSERT INTO users VALUES(170,'tenant17@loca.com','+221770000025','$2a$12$UHvKwyDPJFLcaD8eVGUq2.3Ed683tYxOloi2hx6o3ww89Ux87ul9u','Michèle','Marchal','tenant',NULL,11,'2026-06-18 21:47:37.064367','2026-06-22 08:49:53.169939',NULL,NULL,1);
INSERT INTO users VALUES(171,'tenant18@loca.com','+221770000026','$2a$12$KCfpKq9pz0TQRyioK5ANmOY.R16VhLVBqQ/rl9YMtKcS1jJVgcPqu','Jourdain','Julien','tenant',NULL,11,'2026-06-18 21:47:37.273513','2026-06-22 08:49:53.173009',NULL,NULL,1);
INSERT INTO users VALUES(172,'tenant19@loca.com','+221770000027','$2a$12$lU6qO3hacFXSti4nTHg/6uxjcKxyt2Ay6VLq.BAAgg4cXpgl3kwTq','Tonnin','Herve','tenant',NULL,11,'2026-06-18 21:47:37.473884','2026-06-22 08:49:53.175831',NULL,NULL,1);
INSERT INTO users VALUES(173,'tenant20@loca.com','+221770000028','$2a$12$67Cw2UQ77ixQdQaXOmnfKuuzsjj6IJlhdtWNeNc2fJofVYxYMNZDK','Adrehilde','Richard','tenant',NULL,11,'2026-06-18 21:47:37.683916','2026-06-22 08:49:53.178566',NULL,NULL,1);
INSERT INTO users VALUES(174,'tenant21@loca.com','+221770000030','$2a$12$N/8Phbr1NVs1vfcnaRo0wOdTne7gixwK9z7VQPxCkwmzTca1uuo5C','Élodie','Lefevre','tenant',NULL,NULL,'2026-06-18 21:47:37.907173','2026-06-22 08:49:53.181302',NULL,NULL,1);
INSERT INTO users VALUES(175,'tenant22@loca.com','+221770000031','$2a$12$0sl/F4AVP2Es3LQIvHCuQelty1toxpo63ao16h/CNtykguxqvxK5i','Rodrigue','Leger','tenant',NULL,NULL,'2026-06-18 21:47:38.116412','2026-06-22 08:49:53.183946',NULL,NULL,1);
INSERT INTO users VALUES(176,'tenant23@loca.com','+221770000032','$2a$12$TvARrWaBz44tZcelY6jAlOi4Zi/Yrz4BEzA.NOHl8YBwgPqT9CLQe','Laurène','Bonnet','tenant',NULL,12,'2026-06-18 21:47:38.329947','2026-06-22 08:49:53.189031',NULL,NULL,1);
INSERT INTO users VALUES(177,'tenant24@loca.com','+221770000033','$2a$12$wOndol2j06brSAQytI9GJu5vZIxEEYPDK3noRkaVeDSPIf2I1q41m','Lucienne','Poulain','tenant',NULL,12,'2026-06-18 21:47:38.532397','2026-06-22 08:49:53.195067',NULL,NULL,1);
INSERT INTO users VALUES(178,'tenant25@loca.com','+221770000034','$2a$12$SKsRmHvClIG9pmKyfn8hp.QBW7PdawrLWFOO2VnUa7ccy1S4NYRiS','Marine','Henry','tenant',NULL,12,'2026-06-18 21:47:38.741373','2026-06-22 08:49:53.208983',NULL,NULL,1);
INSERT INTO users VALUES(179,'tenant26@loca.com','+221770000035','$2a$12$Q7H6BgXPC/OhM0PI7yZ3e.uDOmesJzpgRqxzJgf9A1022v0yQ8/W2','Antigone','Breton','tenant',NULL,12,'2026-06-18 21:47:38.953931','2026-06-22 08:49:53.211710',NULL,NULL,1);
INSERT INTO users VALUES(180,'tenant27@loca.com','+221770000036','$2a$12$qK1nuKQj1ew8zCj84s3CZeLo1.cYBoUyBhMDkSIeJ.r9/XzoaWVGe','Constance','Perret','tenant',NULL,12,'2026-06-18 21:47:39.175138','2026-06-22 08:49:53.214323',NULL,NULL,1);
INSERT INTO users VALUES(181,'tenant28@loca.com','+221770000037','$2a$12$8yganpH8tPmJXmi34o6iF.e8KQcyx12GT9xVpp/YZ2IotThIIcGSW','Garance','Laporte','tenant',NULL,12,'2026-06-18 21:47:39.398279','2026-06-22 08:49:53.216878',NULL,NULL,1);
INSERT INTO users VALUES(182,'tenant29@loca.com','+221770000038','$2a$12$8LXxC5DrRBnhqo62ZRzG4uMuxVICdoYvruOPWkDoomh.eUEbBmUkK','Edgard','Méunier','tenant',NULL,12,'2026-06-18 21:47:39.617126','2026-06-22 08:49:53.219398',NULL,NULL,1);
INSERT INTO users VALUES(183,'tenant30@loca.com','+221770000039','$2a$12$aD.3h.DO2EFMfJcSiKWu/.rqQf4QlxIE02AdLK5APspxD.//hRpj2','Isidore','Barbier','tenant',NULL,12,'2026-06-18 21:47:39.837667','2026-06-22 08:49:53.221867',NULL,NULL,1);
INSERT INTO users VALUES(184,'tenant31@loca.com','+221770000040','$2a$12$qVlDARFXBhz3ZRkh1NSR8.7quR/.WcTZC.xzpY4srTmdwbsiiwDGK','Rictrude','Breton','tenant',NULL,12,'2026-06-18 21:47:40.040057','2026-06-22 08:49:53.224249',NULL,NULL,1);
INSERT INTO users VALUES(185,'tenant32@loca.com','+221770000041','$2a$12$rQeGNTJr5pPE.lQJtQuy3.fBONov/VMZt1qzuZArFD5T2Qrt8ZNzK','Assomption','Collet','tenant',NULL,12,'2026-06-18 21:47:40.240146','2026-06-22 08:49:53.226756',NULL,NULL,1);
INSERT INTO users VALUES(186,'tenant33@loca.com','+221770000042','$2a$12$aMO750IdtrTZ6si5L7v9De3plavWeX/BBcKYn15yemEmsUPbeEbD6','Antoine','Dumas','tenant',NULL,12,'2026-06-18 21:47:40.446260','2026-06-22 08:49:53.229144',NULL,NULL,1);
INSERT INTO users VALUES(187,'tenant34@loca.com','+221770000043','$2a$12$GQh6DMr3jhjQABmZHR2VRuZiccF0850FPWFOhnyMGIBvskg2r//4q','Armandine','Charles','tenant',NULL,12,'2026-06-18 21:47:40.650757','2026-06-22 08:49:53.231570',NULL,NULL,1);
INSERT INTO users VALUES(188,'tenant35@loca.com','+221770000044','$2a$12$HSf/IX6G9Kh6BGSmvCw.ueFXHaFcnJeQqncvzYzOa6Xn4IqH196Jq','Guillemette','Lefevre','tenant',NULL,12,'2026-06-18 21:47:40.856049','2026-06-22 08:49:53.234085',NULL,NULL,1);
INSERT INTO users VALUES(189,'tenant36@loca.com','+221770000045','$2a$12$.lT1fXJmCr18qfU4LNdxhuWAYb7BBAsnt0FFTcfOhET.OMPfsbPnu','Justine','Guerin','tenant',NULL,12,'2026-06-18 21:47:41.055237','2026-06-22 08:49:53.236443',NULL,NULL,1);
INSERT INTO users VALUES(190,'tenant37@loca.com','+221770000046','$2a$12$6PLo8Ri2A9KwnTRfMRbt5.P//rUNrVPK0uiFaSNZuG8M538pZf53C','Philippe','Julien','tenant',NULL,12,'2026-06-18 21:47:41.255070','2026-06-22 08:49:53.238845',NULL,NULL,1);
INSERT INTO users VALUES(191,'tenant38@loca.com','+221770000047','$2a$12$igFT.uf/w61VzeV95F48vO3Cz4y4wPf8WDtSkUs3.OLzuXLL1ex7K','Normand','Lemaire','tenant',NULL,12,'2026-06-18 21:47:41.454693','2026-06-22 08:49:53.246860',NULL,NULL,1);
INSERT INTO users VALUES(192,'tenant39@loca.com','+221770000048','$2a$12$wzZOv92UNJev5TCD8UzzzuHlUbw4HiibKaT/g5Q0iyZR43ilEChIW','Francisque','Collet','tenant',NULL,12,'2026-06-18 21:47:41.662136','2026-06-22 08:49:53.249875',NULL,NULL,1);
INSERT INTO users VALUES(193,'tenant40@loca.com','+221770000049','$2a$12$Lunxx.reXyHVFaLMYzKPvufE8p7o6X22yhi.T6/0.yovg86lpb/SK','Coraline','Le roux','tenant',NULL,12,'2026-06-18 21:47:41.864624','2026-06-22 08:49:53.252630',NULL,NULL,1);
INSERT INTO users VALUES(194,'tenant41@loca.com','+221770000051','$2a$12$TvmsSnBf.uOUbzkADnzKEeHaYe2hy3wBQ6wbnGf8GJ7jOgmtRqBYG','Clarisse','Collin','tenant',NULL,13,'2026-06-18 21:47:42.076373','2026-06-22 08:49:53.255138',NULL,NULL,1);
INSERT INTO users VALUES(195,'tenant42@loca.com','+221770000052','$2a$12$OVyf/a.OeNlU0ginM9BQfuipoPDZq2we1wJ98rzEYk6v8qfpI/2La','Marjorie','Le Roux','tenant',NULL,13,'2026-06-18 21:47:42.296879','2026-06-22 08:49:53.257676',NULL,NULL,1);
INSERT INTO users VALUES(196,'tenant43@loca.com','+221770000053','$2a$12$HjGMZsxVEDMl98uAKmS42OwL4s6Na0ZNkFJoThjQCnCeQS1OX32uu','Néhémie','Germain','tenant',NULL,13,'2026-06-18 21:47:42.512312','2026-06-22 08:49:53.260133',NULL,NULL,1);
INSERT INTO users VALUES(197,'tenant44@loca.com','+221770000054','$2a$12$Jer7gDqI63fyJgYXb287Ve7b4ahEGS1Ur0.6/Fvzv/HT11WRROU/q','Roger','Hamon','tenant',NULL,13,'2026-06-18 21:47:42.722590','2026-06-22 08:49:53.262588',NULL,NULL,1);
INSERT INTO users VALUES(198,'tenant45@loca.com','+221770000055','$2a$12$BIHk8qDeqUOTwMuX1OSNKOVIdW.zZeitruY.BvUw8idLEJiOLI6GC','Vinciane','Collin','tenant',NULL,13,'2026-06-18 21:47:42.925075','2026-06-22 08:49:53.265110',NULL,NULL,1);
INSERT INTO users VALUES(199,'tenant46@loca.com','+221770000056','$2a$12$NjFLnNyBl8T88FWA95FEVufs6zNn.ofJGPxEp5Z9Dl1ORWF5IwSfO','Acacie','Garcia','tenant',NULL,13,'2026-06-18 21:47:43.131134','2026-06-22 08:49:53.267576',NULL,NULL,1);
INSERT INTO users VALUES(200,'tenant47@loca.com','+221770000057','$2a$12$.QZKHoK1asZUXAtqVOtl8.K90sxJX9QpCgPZIg6mh7TlBzy1av/06','Éliane','Dupuy','tenant',NULL,13,'2026-06-18 21:47:43.266187','2026-06-22 08:49:53.269992',NULL,NULL,1);
INSERT INTO users VALUES(201,'tenant48@loca.com','+221770000058','$2a$12$pVNb4ztzmnIqjc/L.rczuOEdf/C5c/JQGhrTtqwMasz0/eHXfVtvm','Paul','Adam','tenant',NULL,13,'2026-06-18 21:47:43.493359','2026-06-22 08:49:53.272520',NULL,NULL,1);
INSERT INTO users VALUES(202,'tenant49@loca.com','+221770000059','$2a$12$JAtJvn1nwEWHyQF2DDxAwOQOYqDOvquCE8QPtQtdPgHYv3209OadC','Adélaïde','Roussel','tenant',NULL,13,'2026-06-18 21:47:43.712186','2026-06-22 08:49:53.275131',NULL,NULL,1);
INSERT INTO users VALUES(203,'tenant50@loca.com','+221770000060','$2a$12$ZrCvDFEUzb6X6umwY7zYvOYtOyeFI2KZmPW2ixEsbMd0NYoqx8lyO','Emma','Arnaud','tenant',NULL,13,'2026-06-18 21:47:43.919344','2026-06-22 08:49:53.277445',NULL,NULL,1);
INSERT INTO users VALUES(204,'tenant51@loca.com','+221770000061','$2a$12$YF3qAzFvoT8D.I3MasJk/.N5alMpDCWZ8l3XiOaAsI9xVT1LPIwT6','Zoé','Pichon','tenant',NULL,13,'2026-06-18 21:47:44.119918','2026-06-22 08:49:53.279869',NULL,NULL,1);
INSERT INTO users VALUES(205,'tenant52@loca.com','+221770000062','$2a$12$3eKZJkti1orVj3bHymlEl.saduW9hTZKwgS1ttrn2LEB2K4diqTTm','Victoire','Vincent','tenant',NULL,13,'2026-06-18 21:47:44.322434','2026-06-22 08:49:53.285612',NULL,NULL,1);
INSERT INTO users VALUES(206,'tenant53@loca.com','+221770000063','$2a$12$cbmS3i1H8mNZy82cx348k.Ubqk0Q48/lAfakebVt2ylB//WqOzlwe','Diane','Chauvin','tenant',NULL,13,'2026-06-18 21:47:44.523268','2026-06-22 08:49:53.288215',NULL,NULL,1);
INSERT INTO users VALUES(207,'tenant54@loca.com','+221770000064','$2a$12$lxqAvOZU7cpk7r/XrewD4.Uyt5ib0Oj3XdzbTa/Vvls8xIIBEMN3S','Aquilin','Jacquet','tenant',NULL,NULL,'2026-06-18 21:47:44.730065','2026-06-22 08:49:53.290840',NULL,NULL,1);
INSERT INTO users VALUES(208,'tenant55@loca.com','+221770000065','$2a$12$K77mMZDhQP67ybKp3f1pruQ1wnQZIo2ILt0XfX.s4WHHyPSPwn5tq','Ariane','Cousin','tenant',NULL,13,'2026-06-18 21:47:44.937907','2026-06-22 08:49:53.293694',NULL,NULL,1);
INSERT INTO users VALUES(209,'tenant56@loca.com','+221770000066','$2a$12$BjH.SA7Z4qy1NnlM9EOjOOkqvSFP.k.KWQbWb3Bie0kZad.yDnmOm','Althée','Rolland','tenant',NULL,13,'2026-06-18 21:47:45.149254','2026-06-22 08:49:53.296185',NULL,NULL,1);
INSERT INTO users VALUES(210,'tenant57@loca.com','+221770000067','$2a$12$kfllMDgtmP183gtJTZfrOeUuXotUyz2pdB.oLvbGExuMfrP/GnqKa','Angoustan','Renard','tenant',NULL,13,'2026-06-18 21:47:45.356290','2026-06-22 08:49:53.298775',NULL,NULL,1);
INSERT INTO users VALUES(211,'tenant58@loca.com','+221770000068','$2a$12$IH/tMh7EkYAv1fko/1EWbu48y9EIKgovc3hApAX/b87grsDFEOYk6','Romane','Lejeune','tenant',NULL,13,'2026-06-18 21:47:45.557929','2026-06-22 08:49:53.301159',NULL,NULL,1);
INSERT INTO users VALUES(212,'tenant59@loca.com','+221770000069','$2a$12$T/o7eakE6nHdy/WB1ezQWOi.UQ4J7PpJBeWeXYO87yWQt3tXD9KB2','Morgane','Gaillard','tenant',NULL,13,'2026-06-18 21:47:45.761386','2026-06-22 08:49:53.303642',NULL,NULL,1);
INSERT INTO users VALUES(213,'tenant60@loca.com','+221770000070','$2a$12$JFGt7dC/DAlxXLQE0WuW6O55Y/wH2uHt8VaOFOeeBb4UsA62xdLh6','Madeleine','Bouchet','tenant',NULL,13,'2026-06-18 21:47:45.968569','2026-06-22 08:49:53.306224',NULL,NULL,1);
INSERT INTO users VALUES(214,'tenant61@loca.com','+221770000072','$2a$12$TbVDERAUKIe9fvUabjIg5e.gSWgUn2a7onVx4M8iIBryMy4b22LUW','Améthyste','Noël','tenant',NULL,14,'2026-06-18 21:47:46.185830','2026-06-22 08:49:53.308585',NULL,NULL,1);
INSERT INTO users VALUES(215,'tenant62@loca.com','+221770000073','$2a$12$5EPbwpkWZQsSmZjSwk3T5.3T4UkSYInsPGowYetVRiB8m.qgBRApW','Angèle','Renault','tenant',NULL,14,'2026-06-18 21:47:46.386849','2026-06-22 08:49:53.311070',NULL,NULL,1);
INSERT INTO users VALUES(216,'tenant63@loca.com','+221770000074','$2a$12$h18ZaC7LJCtlGlRsuFZzhuKBSKyXR3sMhwyayJ574W.hf7jLiCa.K','Gatien','Benard','tenant',NULL,14,'2026-06-18 21:47:46.588658','2026-06-22 08:49:53.313521',NULL,NULL,1);
INSERT INTO users VALUES(217,'tenant64@loca.com','+221770000075','$2a$12$HoEzGSLQGxsXgvQ/o7I7XebVMGbZiaZAnmwcYFPLXoDLN6FbK4P4.','Marceau','Noel','tenant',NULL,14,'2026-06-18 21:47:46.792608','2026-06-22 08:49:53.315983',NULL,NULL,1);
INSERT INTO users VALUES(218,'tenant65@loca.com','+221770000076','$2a$12$ymXRDRtuy2TUDTQPWy3Ddesi7cqcTpVD8zAcry1GWWpNRKd05Eo2q','Longin','Philippe','tenant',NULL,14,'2026-06-18 21:47:46.996211','2026-06-22 08:49:53.318420',NULL,NULL,1);
INSERT INTO users VALUES(219,'tenant66@loca.com','+221770000077','$2a$12$9LoRKX6f0lST1DyqVmmYbuPI9AHNxFbhzvLMy3tUufvYie7MOQk6e','Sébastien','Perrot','tenant',NULL,14,'2026-06-18 21:47:47.196324','2026-06-22 08:49:53.321681',NULL,NULL,1);
INSERT INTO users VALUES(220,'tenant67@loca.com','+221770000078','$2a$12$gVb3wBljbwwBJkPoqqz2K.DJoOeAus/Hdt2ctJpMUnD/Wf0rkaeVa','Océane','Lecomte','tenant',NULL,14,'2026-06-18 21:47:47.394103','2026-06-22 08:49:53.324291',NULL,NULL,1);
INSERT INTO users VALUES(221,'tenant68@loca.com','+221770000079','$2a$12$aAQN8sSoS5zJQU.6gyZiIO4G13hjDFPuReGH1az1Zm2ofVojVCWU6','Quentine','Mathieu','tenant',NULL,14,'2026-06-18 21:47:47.592941','2026-06-22 08:49:53.326751',NULL,NULL,1);
INSERT INTO users VALUES(222,'tenant69@loca.com','+221770000080','$2a$12$Z1Hr9l66uwXy2NOhKXgF7e1LaA/UxVyq/TpVf5fwTeqcP5.H8soXG','Clélie','Guillaume','tenant',NULL,14,'2026-06-18 21:47:47.793443','2026-06-22 08:49:53.329296',NULL,NULL,1);
INSERT INTO users VALUES(223,'tenant70@loca.com','+221770000081','$2a$12$WtFe2Dtk5E1isvMqNE3Gsuc4tdcI.jxjCnB/A2PVQNUFu4syb9vYC','Auriane','Michaud','tenant',NULL,14,'2026-06-18 21:47:48.001216','2026-06-22 08:49:53.331853',NULL,NULL,1);
INSERT INTO users VALUES(224,'tenant71@loca.com','+221770000082','$2a$12$Ofz1Uu8Yol7XylYJr1pXCOqil8KYuxIp2RQVwxa0TmGjOGXEx29cy','Élise','Dumont','tenant',NULL,14,'2026-06-18 21:47:48.202075','2026-06-22 08:49:53.334149',NULL,NULL,1);
INSERT INTO users VALUES(225,'tenant72@loca.com','+221770000083','$2a$12$q9V52p8yerdANE2UJL/Ni.q8kwjqryw2lq0LidFSzLDbsq1LOI5CG','Marlène','Sanchez','tenant',NULL,14,'2026-06-18 21:47:48.402359','2026-06-22 08:49:53.336693',NULL,NULL,1);
INSERT INTO users VALUES(226,'tenant73@loca.com','+221770000084','$2a$12$NphSROoGVsFaStroFP14IeAhb.UfN0raLmJyHv8m2sEsHYK23BL8G','Absalon','Vincent','tenant',NULL,14,'2026-06-18 21:47:48.602929','2026-06-22 08:49:53.339210',NULL,NULL,1);
INSERT INTO users VALUES(227,'tenant74@loca.com','+221770000085','$2a$12$.OHPO3VazkIgyRBb9CL50.seZ5rHIaIuxSNc9dWP49.ir7SpxB2Gi','Didier','Carre','tenant',NULL,14,'2026-06-18 21:47:48.803540','2026-06-22 08:49:53.341644',NULL,NULL,1);
INSERT INTO users VALUES(228,'tenant75@loca.com','+221770000086','$2a$12$yl9IXX7ACg2K9BqZLFzVV.FapO6H6T/kz93fixLRSdS7THPfhSS7K','Isabelle','Bailly','tenant',NULL,14,'2026-06-18 21:47:49.007436','2026-06-22 08:49:53.344171',NULL,NULL,1);
INSERT INTO users VALUES(229,'tenant76@loca.com','+221770000087','$2a$12$2U2jg1EMIe987sWcT1LEuOyFyyyCB.bn5nwF55EYx.6m0/bjXYi0e','Tonnin','Morin','tenant',NULL,14,'2026-06-18 21:47:49.206038','2026-06-22 08:49:53.346612',NULL,NULL,1);
INSERT INTO users VALUES(230,'tenant77@loca.com','+221770000088','$2a$12$6ZQ8Bd.iS8FTi22lz5HN5OMPMWMi7J7Iod0v8XWB629EwXEU1zZz6','Cassien','Moulin','tenant',NULL,14,'2026-06-18 21:47:49.404768','2026-06-22 08:49:53.349216',NULL,NULL,1);
INSERT INTO users VALUES(231,'tenant78@loca.com','+221770000089','$2a$12$W/AGQp6.N.thCtT7BbWgauTDG78XFeYU4MzdO5dwRE8im0YZKPHV6','Augustine','Mercier','tenant',NULL,14,'2026-06-18 21:47:49.605844','2026-06-22 08:49:53.351568',NULL,NULL,1);
INSERT INTO users VALUES(232,'tenant79@loca.com','+221770000090','$2a$12$7h0iIicW2dDndZys5Egi/.iNds5MVA6.bqyCKfXlRAXbHdIjqficO','Clémentine','Martin','tenant',NULL,14,'2026-06-18 21:47:49.804360','2026-06-22 08:49:53.354727',NULL,NULL,1);
INSERT INTO users VALUES(233,'tenant80@loca.com','+221770000091','$2a$12$9N0FS6.sPdUERi2ZTGUEwOyMmzl/UhjA9JP4jvyMKjQ.XP2EQ474e','Achille','Millet','tenant',NULL,14,'2026-06-18 21:47:50.002966','2026-06-22 08:49:53.357212',NULL,NULL,1);
INSERT INTO users VALUES(234,'tenant81@loca.com','+221770000093','$2a$12$IUQSAOrgpkcrhemmK8JWquP2ltLnBTJVSYJI3s/y/olPM8OFjX8Qu','Solange','Duval','tenant',NULL,15,'2026-06-18 21:47:50.208816','2026-06-22 08:49:53.359716',NULL,NULL,1);
INSERT INTO users VALUES(235,'tenant82@loca.com','+221770000094','$2a$12$ZeVtLRg1BkKDe2cwm7htd.OTwglgVusKZIAt1WNYljBZ6ErHTp3ge','Ségolène','Marie','tenant',NULL,15,'2026-06-18 21:47:50.408368','2026-06-22 08:49:53.362315',NULL,NULL,1);
INSERT INTO users VALUES(236,'tenant83@loca.com','+221770000095','$2a$12$u639sHcrBY611.E38T0O9.4eaA3QWFb7o34X.Q2ix0pm6zKRj6gh.','Audeline','Blanchard','tenant',NULL,15,'2026-06-18 21:47:50.606629','2026-06-22 08:49:53.364755',NULL,NULL,1);
INSERT INTO users VALUES(237,'tenant84@loca.com','+221770000096','$2a$12$LqLVfZOMnqN1iELQsLzOMeZUlIA1djxK3jbjr5xY0HcGPMewY4hE6','Rodrigue','Cousin','tenant',NULL,15,'2026-06-18 21:47:50.804410','2026-06-22 08:49:53.367497',NULL,NULL,1);
INSERT INTO users VALUES(238,'tenant85@loca.com','+221770000097','$2a$12$n7cgy09.wU917y81PU1tHOgF0UkbExJG.UKXK4RN9A/QoOU/jeKCu','Armandine','Nguyen','tenant',NULL,15,'2026-06-18 21:47:51.004244','2026-06-22 08:49:53.370128',NULL,NULL,1);
INSERT INTO users VALUES(239,'tenant86@loca.com','+221770000098','$2a$12$59ss/Qbp6i6oxK2zDnXDcuMPqp.nBoNdeoV9sINd0ZybC/5n.IsFW','Eudoxie','Méunier','tenant',NULL,15,'2026-06-18 21:47:51.203161','2026-06-22 08:49:53.372588',NULL,NULL,1);
INSERT INTO users VALUES(240,'tenant87@loca.com','+221770000099','$2a$12$Eflh/wC.JCODTguQx5yvZuWMSFPFKpon15iCxcgpOCBvPn85vJc.i','Aurélienne','Guérin','tenant',NULL,15,'2026-06-18 21:47:51.404672','2026-06-22 08:49:53.375193',NULL,NULL,1);
INSERT INTO users VALUES(241,'tenant88@loca.com','+221770000100','$2a$12$RRJPWo93WP48/zc5S6/awOEZieyLq4zbm3Xrz1ga42TjZySOVkde2','Joël','Bernard','tenant',NULL,15,'2026-06-18 21:47:51.615629','2026-06-22 08:49:53.377675',NULL,NULL,1);
INSERT INTO users VALUES(242,'tenant89@loca.com','+221770000101','$2a$12$2NGugB8PXZEGFih3dikvNuRKQx8JddQ64Hvw1MvnVu3Wc45JJ60Ci','Noël','Moulin','tenant',NULL,15,'2026-06-18 21:47:51.821833','2026-06-22 08:49:53.380150',NULL,NULL,1);
INSERT INTO users VALUES(243,'tenant90@loca.com','+221770000102','$2a$12$wnll1zEti.El1vZz.MWeWucwflPOavjr.iaYQvxF1cTeX4Df3I0yu','Henryane','Lebrun','tenant',NULL,15,'2026-06-18 21:47:52.024294','2026-06-22 08:49:53.382590',NULL,NULL,1);
INSERT INTO users VALUES(244,'tenant91@loca.com','+221770000103','$2a$12$8ROgU.pCBcBp9c9BKzqrju2cvv/R.ty6prz7R37b5f0uKNfPa80.W','Valérie','Bernard','tenant',NULL,15,'2026-06-18 21:47:52.228567','2026-06-22 08:49:53.385133',NULL,NULL,1);
INSERT INTO users VALUES(245,'tenant92@loca.com','+221770000104','$2a$12$bVrKF7z4b9SnBoMmefAkwuwoP0uCh5pXjDPdcTnOUK2gu2d0SSEFC','Ysaline','Berger','tenant',NULL,15,'2026-06-18 21:47:52.429731','2026-06-22 08:49:53.387551',NULL,NULL,1);
INSERT INTO users VALUES(246,'tenant93@loca.com','+221770000105','$2a$12$zn2gnMtImtYCsdp/BB.n2OWP3FFzGWacez052QxwUvVcMxjpNSmBm','Lionel','Guichard','tenant',NULL,15,'2026-06-18 21:47:52.630655','2026-06-22 08:49:53.390744',NULL,NULL,1);
INSERT INTO users VALUES(247,'tenant94@loca.com','+221770000106','$2a$12$N5E8OsunduelGp2/kpRPkuzONN2tzIJVpIyc8dS/B1ZWhSzcd8Pom','Gaëlle','Hoarau','tenant',NULL,15,'2026-06-18 21:47:52.832257','2026-06-22 08:49:53.393277',NULL,NULL,1);
INSERT INTO users VALUES(248,'tenant95@loca.com','+221770000107','$2a$12$AznaBD890KJ5b6RHmG/gj.ouxxxD6CCzLqdCrkG5HIPON2o/.nzF.','Agrippin','Fontaine','tenant',NULL,15,'2026-06-18 21:47:53.033531','2026-06-22 08:49:53.395832',NULL,NULL,1);
INSERT INTO users VALUES(249,'tenant96@loca.com','+221770000108','$2a$12$VMDxMQ2.NNHx90PyVtQGGeAaIbyHqbQe3ZOi.H8ZmC.zsk4lU1F3q','Azalée','Guillot','tenant',NULL,15,'2026-06-18 21:47:53.235283','2026-06-22 08:49:53.398339',NULL,NULL,1);
INSERT INTO users VALUES(250,'tenant97@loca.com','+221770000109','$2a$12$OWMiOG3mS6evW5zm5QgKeecYEqqOuJfPKn8knQPbAkCBt8Ot4eSAe','Diane','Benard','tenant',NULL,15,'2026-06-18 21:47:53.434661','2026-06-22 08:49:53.400895',NULL,NULL,1);
INSERT INTO users VALUES(251,'tenant98@loca.com','+221770000110','$2a$12$VLNxo0BUOtgPBcpvz6/CHu1ZLsn.Lcdd9BpBTskbkbNLI.KYinfE.','Léonard','Poulain','tenant',NULL,15,'2026-06-18 21:47:53.632261','2026-06-22 08:49:53.403408',NULL,NULL,1);
INSERT INTO users VALUES(252,'tenant99@loca.com','+221770000111','$2a$12$0llUOyDDpbyfSbCuim6uPePdRdWXsEqyxJQH2K2vpDq/Vy4PI8lQe','Ambroisie','Perrot','tenant',NULL,15,'2026-06-18 21:47:53.831179','2026-06-22 08:49:53.405949',NULL,NULL,1);
INSERT INTO users VALUES(253,'tenant100@loca.com','+221770000112','$2a$12$5IDP.BZcg.GxC8Y..RmBgeDCEULpNUxpptEUMDVQ6RiPEq0h9ae3O','Jérôme','Schneider','tenant',NULL,15,'2026-06-18 21:47:54.041313','2026-06-22 08:49:53.408337',NULL,NULL,1);
INSERT INTO users VALUES(254,'tenant101@loca.com','+221770000114','$2a$12$/JJtG3tSFRFFnbIlR/ou5.dkioCUHc9Oyhu/KYED/UIWe1GBGFCzW','Sylviane','Hubert','tenant',NULL,16,'2026-06-18 21:47:54.247476','2026-06-22 08:49:53.410837',NULL,NULL,1);
INSERT INTO users VALUES(255,'tenant102@loca.com','+221770000115','$2a$12$Ny6faGKZHL8WBP.FsH4NbeU90/9r5VFKzYtLO8mE5cUCsVDUaElpG','Soline','Clement','tenant',NULL,16,'2026-06-18 21:47:54.445338','2026-06-22 08:49:53.413243',NULL,NULL,1);
INSERT INTO users VALUES(256,'tenant103@loca.com','+221770000116','$2a$12$NcYBbOagNXQqZFrLg1Ktsuq7AeH/oaVa0DR6qbtDmxwZlSeFQrX36','Archange','Colin','tenant',NULL,16,'2026-06-18 21:47:54.654295','2026-06-22 08:49:53.415828',NULL,NULL,1);
INSERT INTO users VALUES(257,'tenant104@loca.com','+221770000117','$2a$12$7gQDpUnlQ4ZUZLDVdoUqAOP1pJfuAXsnOeO7aTPKiwVLvCBerFngW','Camillien','Laporte','tenant',NULL,16,'2026-06-18 21:47:54.891887','2026-06-22 08:49:53.418198',NULL,NULL,1);
INSERT INTO users VALUES(258,'tenant105@loca.com','+221770000118','$2a$12$usiH4h9UHm.PqVdDrmz2xeH0RzEjlBL0l7JGCMt4cX8cF4aN1UC7m','Mélisse','Rémy','tenant',NULL,16,'2026-06-18 21:47:55.130624','2026-06-22 08:49:53.420773',NULL,NULL,1);
INSERT INTO users VALUES(259,'tenant106@loca.com','+221770000119','$2a$12$JlhnZwC4.rSs.u6xUBfS6.6DHB6kmT9k74mKMfcNL.k.KWjcqG.p2','Claudine','Brunet','tenant',NULL,16,'2026-06-18 21:47:55.349561','2026-06-22 08:49:53.423226',NULL,NULL,1);
INSERT INTO users VALUES(260,'tenant107@loca.com','+221770000120','$2a$12$W4v632hrqwABfLK3dwRtG.MmExiRvCbgJ.hERYZcY6UpXZEUDJIpW','Maurice','Leveque','tenant',NULL,16,'2026-06-18 21:47:55.568257','2026-06-22 08:49:53.426497',NULL,NULL,1);
INSERT INTO users VALUES(261,'tenant108@loca.com','+221770000121','$2a$12$dIrXmTk/WdqyhF8/ttsNAe5pwtHh9g9sYzuy.MYYWb.27O7qm5zb2','Clémence','Rolland','tenant',NULL,16,'2026-06-18 21:47:55.791284','2026-06-22 08:49:53.429058',NULL,NULL,1);
INSERT INTO users VALUES(262,'tenant109@loca.com','+221770000122','$2a$12$IAqv3umdlPd8C0Evv0jHf.daCPp0/3PaUe9E85kHRHdEbahYTxGTK','Hector','Guérin','tenant',NULL,16,'2026-06-18 21:47:56.003500','2026-06-22 08:49:53.431578',NULL,NULL,1);
INSERT INTO users VALUES(263,'tenant110@loca.com','+221770000123','$2a$12$n6EusCuBCnFuBUopsGaBGOdxtYYwqnG1.QkxI5LeQJ3sGIcu8ZJ0K','Samuel','Michaud','tenant',NULL,16,'2026-06-18 21:47:56.222744','2026-06-22 08:49:53.434142',NULL,NULL,1);
INSERT INTO users VALUES(264,'tenant111@loca.com','+221770000124','$2a$12$jNgF0uD7aMdZ8taukGXkcO49rKZpjtYIBQxHO0KMqPxHT0a9H1eUW','Mauricette','Richard','tenant',NULL,16,'2026-06-18 21:47:56.435077','2026-06-22 08:49:53.436588',NULL,NULL,1);
INSERT INTO users VALUES(265,'tenant112@loca.com','+221770000125','$2a$12$DHaMFf8ixecbCbn7RXo71OLZRsi7H/rhcCmMvEqQiU4yumwQhMxQu','Job','Riviere','tenant',NULL,16,'2026-06-18 21:47:56.641158','2026-06-22 08:49:53.439043',NULL,NULL,1);
INSERT INTO users VALUES(266,'tenant113@loca.com','+221770000126','$2a$12$bw041eOd7v3/xglfpbCc6.PfiW4JhEsjcyHui3nCzzFaX/875LTkS','Noé','Poirier','tenant',NULL,16,'2026-06-18 21:47:56.851960','2026-06-22 08:49:53.441755',NULL,NULL,1);
INSERT INTO users VALUES(267,'tenant114@loca.com','+221770000127','$2a$12$xc.tjOo6MvBmVQs4clIQrOGdvG6tDzQ0ockEOLy4vn6BZsqOvZWWq','Martin','Lemoine','tenant',NULL,16,'2026-06-18 21:47:57.060908','2026-06-22 08:49:53.444308',NULL,NULL,1);
INSERT INTO users VALUES(268,'tenant115@loca.com','+221770000128','$2a$12$82IUzkSd8Mx/1aDOKsXVOelKAF5W1FC5Fuv9v4SAzDnc89vZ9i.L2','Laureline','Daniel','tenant',NULL,16,'2026-06-18 21:47:57.275911','2026-06-22 08:49:53.446857',NULL,NULL,1);
INSERT INTO users VALUES(269,'tenant116@loca.com','+221770000129','$2a$12$Gwy8R0T8Kq1eXKB3felgQeYpugMS1tvSN9AJ2qNW5H/Q8K7UqwXHe','Sigismond','Renault','tenant',NULL,16,'2026-06-18 21:47:57.480656','2026-06-22 08:49:53.449437',NULL,NULL,1);
INSERT INTO users VALUES(270,'tenant117@loca.com','+221770000130','$2a$12$.oLz0YIk7NuGaKeg1rNgyePqr9X1Wvw/6KCSadXFJABE1CExi/6TG','Roger','Dupont','tenant',NULL,16,'2026-06-18 21:47:57.685850','2026-06-22 08:49:53.451936',NULL,NULL,1);
INSERT INTO users VALUES(271,'tenant118@loca.com','+221770000131','$2a$12$ZXlLiBDRqSXSCrTeNmhuDuH0BamIE4aMfVoLN/kXR/LGq5I0Jtbfe','Timoléon','Leroux','tenant',NULL,16,'2026-06-18 21:47:57.893461','2026-06-22 08:49:53.454528',NULL,NULL,1);
INSERT INTO users VALUES(272,'tenant119@loca.com','+221770000132','$2a$12$BY5PJ9vWH2JFvJAC3uweb.57DDjlWD3OCCTVUrGSSuUGSn7E4rxJW','Gilberte','Clément','tenant',NULL,16,'2026-06-18 21:47:58.107367','2026-06-22 08:49:53.456885',NULL,NULL,1);
INSERT INTO users VALUES(273,'tenant120@loca.com','+221770000133','$2a$12$CR.5WEflbVXn/j8skgEz7Odl9aDW7DflTuRvHMwOyDdIyzmt8Ea1i','Aure','Dupuy','tenant',NULL,16,'2026-06-18 21:47:58.313555','2026-06-22 08:49:53.460047',NULL,NULL,1);
INSERT INTO users VALUES(274,'nouveau@loca.com','+221770000134','$2a$12$8Qv80MFtxu49IvpMtTW6r.eye8J3yxErgdwnsqxveAt3bHJ.uyDHu','Nouveau','Locataire','tenant',NULL,NULL,'2026-06-18 21:47:58.524537','2026-06-22 08:49:53.462739',NULL,NULL,1);
INSERT INTO users VALUES(275,'dermouhamadou@gmail.com','779164239','$2a$12$U3Z7rp9wqkJcp9AQY8ihYebwzBJE0N5bJkLNgBiYm4kSVyy8JFmf2','Mouhamadou','Der','tenant',NULL,13,'2026-06-18 21:51:30.772967','2026-06-22 09:16:05.225889',NULL,NULL,2);
INSERT INTO users VALUES(276,'test-assign@loca.com','+221771111111','$2a$12$WK5fgXJ/UE9YHYzv0b45me5x8jffkk0kXrjbqkbMB/wyL1nUl.ds6','Test','User','tenant',NULL,NULL,'2026-06-18 21:53:22.571671','2026-06-22 08:49:53.467962',NULL,NULL,1);
INSERT INTO users VALUES(277,'lom@mail.com','769332248','$2a$12$Z7TyZg35Lj85CCkeFpT7u.cAybk7r.NfUJ/SrNf7yhEHJQi4Ycol6','Malick','Lo','tenant',NULL,NULL,'2026-06-19 07:42:00.577829','2026-06-22 08:49:53.470453',NULL,NULL,1);
INSERT INTO users VALUES(278,'thomas.vincent@mail.com','+221770000008','$2a$12$Sjc1AGSRQmjPaMvZV0wTu.IYo/QOqdBsboaVzRcxSpGBddSdWJr0W','Thomas','Vincent','owner',NULL,NULL,'2026-06-19 15:44:11.433701','2026-06-20 16:24:48.017824',NULL,NULL,NULL);
INSERT INTO users VALUES(279,'immoder@mail.com','766217518','$2a$12$onsuZOJHk9oXFapbH5WOQuzIwKOb7Q3MVzddKauC6U.JY8IChO5I6','','','agence',14,NULL,'2026-06-19 20:15:20.846830','2026-06-19 20:15:20.846830',NULL,NULL,NULL);
CREATE TABLE IF NOT EXISTS "agencies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "address" varchar, "phone" varchar, "email" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
INSERT INTO agencies VALUES(12,'Agence Immobilière Dakar','123 Rue Principale, Dakar','+221770000004','contact@agence-dakar.com','2026-06-18 21:47:32.901287','2026-06-18 21:47:32.901287');
INSERT INTO agencies VALUES(13,'Groupe Patrimoine Sénégal','67 Boulevard de la République, Dakar','+221770000005','contact@groupe-patrimoine.sn','2026-06-18 21:47:32.902893','2026-06-18 21:47:32.902893');
INSERT INTO agencies VALUES(14,'Der Immo',NULL,NULL,NULL,'2026-06-19 20:15:20.842361','2026-06-19 20:15:20.842361');
CREATE TABLE IF NOT EXISTS "owners" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar NOT NULL, "last_name" varchar NOT NULL, "phone" varchar, "email" varchar, "agency_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_1f35333df5"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
INSERT INTO owners VALUES(11,'Mass','Mboup','+221770000008','thomas.vincent@mail.com',12,'2026-06-18 21:47:33.446500','2026-06-19 15:46:47.282570');
INSERT INTO owners VALUES(12,'Clarence','Clement','+221770000029','mignon@kihn-connelly.test',12,'2026-06-18 21:47:37.690441','2026-06-18 21:47:37.690441');
INSERT INTO owners VALUES(13,'Alphonsine','Michel','+221770000050','brad_leffler@breitenberg-bernhard.example',12,'2026-06-18 21:47:41.870915','2026-06-18 21:47:41.870915');
INSERT INTO owners VALUES(14,'Pulchérie','Guichard','+221770000071','terrence@quitzon-hintz.test',13,'2026-06-18 21:47:45.975706','2026-06-18 21:47:45.975706');
INSERT INTO owners VALUES(15,'Théophile','Mercier','+221770000092','randal@lemke.example',13,'2026-06-18 21:47:50.009388','2026-06-18 21:47:50.009388');
INSERT INTO owners VALUES(16,'Arielle','Simon','+221770000113','martin@wolf-walsh.test',13,'2026-06-18 21:47:54.048343','2026-06-18 21:47:54.048343');
INSERT INTO owners VALUES(17,'Mouhamadou','Der','779164239','dermouhamadou@gmail.com',12,'2026-06-20 08:03:26.805275','2026-06-20 08:03:26.805275');
CREATE TABLE IF NOT EXISTS "buildings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "address" varchar NOT NULL, "neighborhood" varchar, "commune" varchar, "latitude" decimal(10,7), "longitude" decimal(10,7), "owner_id" integer NOT NULL, "agency_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "photo" varchar, CONSTRAINT "fk_rails_b8dfe07c9e"
FOREIGN KEY ("owner_id")
  REFERENCES "owners" ("id")
, CONSTRAINT "fk_rails_235930fc52"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
INSERT INTO buildings VALUES(11,'Résidence Les Cocotiers','45 Avenue de la République','Fann','Dakar',14.65955259999999961,-17.40552410000000094,11,12,'2026-06-18 21:47:33.451620','2026-06-18 21:47:33.451620',NULL);
INSERT INTO buildings VALUES(12,'Villa Oasis','12 Rue des Manguiers','Sicap','Dakar',14.71850350000000062,-17.42524099999999976,12,12,'2026-06-18 21:47:37.691620','2026-06-18 21:47:37.691620',NULL);
INSERT INTO buildings VALUES(13,'Immeuble Le Rayon','8 Boulevard du Sud','Mermoz','Dakar',14.69452700000000078,-17.47948969999999846,13,12,'2026-06-18 21:47:41.872093','2026-06-18 21:47:41.872093',NULL);
INSERT INTO buildings VALUES(14,'Résidence du Port','23 Quai des Pêcheurs','Gorée','Dakar',14.69836440000000088,-17.39715350000000172,14,13,'2026-06-18 21:47:45.978492','2026-06-18 21:47:45.978492',NULL);
INSERT INTO buildings VALUES(15,'Cité Baobab','55 Avenue Cheikh Anta Diop','Ouakam','Dakar',14.65650559999999914,-17.44084249999999869,15,13,'2026-06-18 21:47:50.010727','2026-06-18 21:47:50.010727',NULL);
INSERT INTO buildings VALUES(16,'Résidence Les Hibiscus','3 Rue de la Plage','Ngor','Dakar',14.73007950000000043,-17.47599710000000072,16,13,'2026-06-18 21:47:54.049602','2026-06-18 21:47:54.049602',NULL);
INSERT INTO buildings VALUES(17,'Immeuble Habibou Ly','Hann Maristes 1 I/lot G63','Hann Masriste','Bel Air',NULL,NULL,11,12,'2026-06-19 15:48:42.170019','2026-06-19 15:48:42.170019',NULL);
INSERT INTO buildings VALUES(18,'Espoir','Diass','Diass Village','Diass commune',NULL,NULL,17,12,'2026-06-20 08:04:04.931811','2026-06-20 08:04:04.931811',NULL);
CREATE TABLE IF NOT EXISTS "apartments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "number" varchar NOT NULL, "floor" integer, "rent_amount" decimal(10,2) NOT NULL, "status" varchar DEFAULT 'free' NOT NULL, "building_id" integer NOT NULL, "tenant_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "photos" text, "visible" boolean DEFAULT 0 NOT NULL, CONSTRAINT "fk_rails_9c46e85795"
FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id")
, CONSTRAINT "fk_rails_9d72b77c1a"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
INSERT INTO apartments VALUES(145,'101',1,120000,'occupied',11,154,'2026-06-18 21:47:33.668607','2026-06-18 21:47:33.668607',NULL,0);
INSERT INTO apartments VALUES(146,'102',1,250000,'occupied',11,155,'2026-06-18 21:47:33.876466','2026-06-18 21:47:33.876466',NULL,0);
INSERT INTO apartments VALUES(147,'103',1,150000,'occupied',11,156,'2026-06-18 21:47:34.090896','2026-06-18 21:47:34.090896',NULL,0);
INSERT INTO apartments VALUES(148,'104',1,200000,'occupied',11,157,'2026-06-18 21:47:34.306528','2026-06-18 21:47:34.306528',NULL,0);
INSERT INTO apartments VALUES(149,'105',1,200000,'occupied',11,158,'2026-06-18 21:47:34.518240','2026-06-18 21:47:34.518240',NULL,0);
INSERT INTO apartments VALUES(150,'206',2,250000,'occupied',11,159,'2026-06-18 21:47:34.735119','2026-06-18 21:47:34.735119',NULL,0);
INSERT INTO apartments VALUES(151,'207',2,120000,'occupied',11,160,'2026-06-18 21:47:34.941092','2026-06-18 21:47:34.941092',NULL,0);
INSERT INTO apartments VALUES(152,'208',2,120000,'occupied',11,161,'2026-06-18 21:47:35.149422','2026-06-18 21:47:35.149422',NULL,0);
INSERT INTO apartments VALUES(153,'209',2,120000,'occupied',11,162,'2026-06-18 21:47:35.375394','2026-06-18 21:47:35.375394',NULL,0);
INSERT INTO apartments VALUES(154,'210',2,250000,'occupied',11,163,'2026-06-18 21:47:35.580187','2026-06-18 21:47:35.580187',NULL,0);
INSERT INTO apartments VALUES(155,'311',3,250000,'occupied',11,164,'2026-06-18 21:47:35.782993','2026-06-18 21:47:35.782993',NULL,0);
INSERT INTO apartments VALUES(156,'312',3,120000,'occupied',11,165,'2026-06-18 21:47:36.008451','2026-06-18 21:47:36.008451',NULL,0);
INSERT INTO apartments VALUES(157,'313',3,200000,'occupied',11,166,'2026-06-18 21:47:36.224840','2026-06-18 21:47:36.224840',NULL,0);
INSERT INTO apartments VALUES(158,'314',3,150000,'occupied',11,167,'2026-06-18 21:47:36.442167','2026-06-18 21:47:36.442167',NULL,0);
INSERT INTO apartments VALUES(159,'315',3,150000,'occupied',11,168,'2026-06-18 21:47:36.661965','2026-06-18 21:47:36.661965',NULL,0);
INSERT INTO apartments VALUES(160,'416',4,250000,'occupied',11,169,'2026-06-18 21:47:36.862601','2026-06-18 21:47:36.862601',NULL,0);
INSERT INTO apartments VALUES(161,'417',4,200000,'occupied',11,170,'2026-06-18 21:47:37.066521','2026-06-18 21:47:37.066521',NULL,0);
INSERT INTO apartments VALUES(162,'418',4,200000,'occupied',11,171,'2026-06-18 21:47:37.275488','2026-06-18 21:47:37.275488',NULL,0);
INSERT INTO apartments VALUES(163,'419',4,250000,'occupied',11,172,'2026-06-18 21:47:37.475792','2026-06-18 21:47:37.475792',NULL,0);
INSERT INTO apartments VALUES(164,'420',4,200000,'occupied',11,173,'2026-06-18 21:47:37.686051','2026-06-18 21:47:37.686051',NULL,0);
INSERT INTO apartments VALUES(165,'X1',5,300000,'free',11,NULL,'2026-06-18 21:47:37.689460','2026-06-18 21:47:37.689460',NULL,0);
INSERT INTO apartments VALUES(166,'101',1,250000,'renovation',12,NULL,'2026-06-18 21:47:37.909329','2026-06-20 19:20:38.855347','["/uploads/apt_166_5553cb6b.jpg","/uploads/apt_166_29c726bd.jpg","/uploads/apt_166_a5372cb9.jpg","/uploads/apt_166_2e170a8e.jpg"]',0);
INSERT INTO apartments VALUES(167,'102',1,150000,'free',12,NULL,'2026-06-18 21:47:38.118613','2026-06-20 17:28:24.222323',NULL,0);
INSERT INTO apartments VALUES(168,'103',1,150000,'occupied',12,176,'2026-06-18 21:47:38.331959','2026-06-18 21:47:38.331959',NULL,0);
INSERT INTO apartments VALUES(169,'104',1,200000,'occupied',12,177,'2026-06-18 21:47:38.534348','2026-06-18 21:47:38.534348',NULL,0);
INSERT INTO apartments VALUES(170,'105',1,120000,'occupied',12,178,'2026-06-18 21:47:38.743635','2026-06-18 21:47:38.743635',NULL,0);
INSERT INTO apartments VALUES(171,'206',2,250000,'occupied',12,179,'2026-06-18 21:47:38.956929','2026-06-18 21:47:38.956929',NULL,0);
INSERT INTO apartments VALUES(172,'207',2,200000,'occupied',12,180,'2026-06-18 21:47:39.183999','2026-06-18 21:47:39.183999',NULL,0);
INSERT INTO apartments VALUES(173,'208',2,200000,'occupied',12,181,'2026-06-18 21:47:39.400814','2026-06-18 21:47:39.400814',NULL,0);
INSERT INTO apartments VALUES(174,'209',2,120000,'occupied',12,182,'2026-06-18 21:47:39.621432','2026-06-18 21:47:39.621432',NULL,0);
INSERT INTO apartments VALUES(175,'210',2,150000,'occupied',12,183,'2026-06-18 21:47:39.839775','2026-06-18 21:47:39.839775',NULL,0);
INSERT INTO apartments VALUES(176,'311',3,150000,'occupied',12,184,'2026-06-18 21:47:40.041963','2026-06-18 21:47:40.041963',NULL,0);
INSERT INTO apartments VALUES(177,'312',3,120000,'occupied',12,185,'2026-06-18 21:47:40.242014','2026-06-18 21:47:40.242014',NULL,0);
INSERT INTO apartments VALUES(178,'313',3,150000,'occupied',12,186,'2026-06-18 21:47:40.448187','2026-06-18 21:47:40.448187',NULL,0);
INSERT INTO apartments VALUES(179,'314',3,150000,'occupied',12,187,'2026-06-18 21:47:40.653146','2026-06-18 21:47:40.653146',NULL,0);
INSERT INTO apartments VALUES(180,'315',3,200000,'occupied',12,188,'2026-06-18 21:47:40.857968','2026-06-18 21:47:40.857968',NULL,0);
INSERT INTO apartments VALUES(181,'416',4,250000,'occupied',12,189,'2026-06-18 21:47:41.057452','2026-06-18 21:47:41.057452',NULL,0);
INSERT INTO apartments VALUES(182,'417',4,150000,'occupied',12,190,'2026-06-18 21:47:41.256995','2026-06-18 21:47:41.256995',NULL,0);
INSERT INTO apartments VALUES(183,'418',4,120000,'occupied',12,191,'2026-06-18 21:47:41.456617','2026-06-18 21:47:41.456617',NULL,0);
INSERT INTO apartments VALUES(184,'419',4,200000,'occupied',12,192,'2026-06-18 21:47:41.664203','2026-06-18 21:47:41.664203',NULL,0);
INSERT INTO apartments VALUES(185,'420',4,250000,'occupied',12,193,'2026-06-18 21:47:41.866503','2026-06-18 21:47:41.866503',NULL,0);
INSERT INTO apartments VALUES(186,'X1',5,300000,'free',12,NULL,'2026-06-18 21:47:41.869676','2026-06-18 21:47:41.869676',NULL,0);
INSERT INTO apartments VALUES(187,'101',1,200000,'occupied',13,194,'2026-06-18 21:47:42.078894','2026-06-18 21:47:42.078894',NULL,0);
INSERT INTO apartments VALUES(188,'102',1,200000,'occupied',13,195,'2026-06-18 21:47:42.299014','2026-06-18 21:47:42.299014',NULL,0);
INSERT INTO apartments VALUES(189,'103',1,200000,'occupied',13,196,'2026-06-18 21:47:42.518168','2026-06-18 21:47:42.518168',NULL,0);
INSERT INTO apartments VALUES(190,'104',1,200000,'occupied',13,197,'2026-06-18 21:47:42.724468','2026-06-18 21:47:42.724468',NULL,0);
INSERT INTO apartments VALUES(191,'105',1,120000,'occupied',13,198,'2026-06-18 21:47:42.927409','2026-06-18 21:47:42.927409',NULL,0);
INSERT INTO apartments VALUES(192,'206',2,200000,'occupied',13,199,'2026-06-18 21:47:43.133199','2026-06-18 21:47:43.133199',NULL,0);
INSERT INTO apartments VALUES(193,'207',2,150000,'occupied',13,200,'2026-06-18 21:47:43.269205','2026-06-18 21:47:43.269205',NULL,0);
INSERT INTO apartments VALUES(194,'208',2,120000,'occupied',13,201,'2026-06-18 21:47:43.495964','2026-06-18 21:47:43.495964',NULL,0);
INSERT INTO apartments VALUES(195,'209',2,120000,'occupied',13,202,'2026-06-18 21:47:43.714487','2026-06-18 21:47:43.714487',NULL,0);
INSERT INTO apartments VALUES(196,'210',2,120000,'occupied',13,203,'2026-06-18 21:47:43.921490','2026-06-18 21:47:43.921490',NULL,0);
INSERT INTO apartments VALUES(197,'311',3,250000,'occupied',13,204,'2026-06-18 21:47:44.121832','2026-06-18 21:47:44.121832',NULL,0);
INSERT INTO apartments VALUES(198,'312',3,250000,'occupied',13,205,'2026-06-18 21:47:44.324596','2026-06-18 21:47:44.324596',NULL,0);
INSERT INTO apartments VALUES(199,'313',3,120000,'occupied',13,206,'2026-06-18 21:47:44.525279','2026-06-18 21:47:44.525279',NULL,0);
INSERT INTO apartments VALUES(200,'314',3,120000,'free',13,NULL,'2026-06-18 21:47:44.732432','2026-06-18 22:00:11.901425',NULL,0);
INSERT INTO apartments VALUES(201,'315',3,200000,'occupied',13,208,'2026-06-18 21:47:44.939989','2026-06-18 21:47:44.939989',NULL,0);
INSERT INTO apartments VALUES(202,'416',4,200000,'occupied',13,209,'2026-06-18 21:47:45.152979','2026-06-18 21:47:45.152979',NULL,0);
INSERT INTO apartments VALUES(203,'417',4,250000,'occupied',13,210,'2026-06-18 21:47:45.358266','2026-06-18 21:47:45.358266',NULL,0);
INSERT INTO apartments VALUES(204,'418',4,250000,'occupied',13,211,'2026-06-18 21:47:45.560330','2026-06-18 21:47:45.560330',NULL,0);
INSERT INTO apartments VALUES(205,'419',4,150000,'occupied',13,212,'2026-06-18 21:47:45.763669','2026-06-18 21:47:45.763669',NULL,0);
INSERT INTO apartments VALUES(206,'420',4,150000,'occupied',13,213,'2026-06-18 21:47:45.970854','2026-06-18 21:47:45.970854',NULL,0);
INSERT INTO apartments VALUES(207,'X1',5,300000,'occupied',13,275,'2026-06-18 21:47:45.974425','2026-06-20 19:32:19.788232','["/uploads/apt_207_b5737ffe.jpg","/uploads/apt_207_d66a22ae.jpg","/uploads/apt_207_d1bcd5db.jpg","/uploads/apt_207_ce1519c6.jpg"]',0);
INSERT INTO apartments VALUES(208,'101',1,150000,'occupied',14,214,'2026-06-18 21:47:46.187777','2026-06-18 21:47:46.187777',NULL,0);
INSERT INTO apartments VALUES(209,'102',1,250000,'occupied',14,215,'2026-06-18 21:47:46.389055','2026-06-18 21:47:46.389055',NULL,0);
INSERT INTO apartments VALUES(210,'103',1,150000,'occupied',14,216,'2026-06-18 21:47:46.590544','2026-06-18 21:47:46.590544',NULL,0);
INSERT INTO apartments VALUES(211,'104',1,250000,'occupied',14,217,'2026-06-18 21:47:46.794710','2026-06-18 21:47:46.794710',NULL,0);
INSERT INTO apartments VALUES(212,'105',1,250000,'occupied',14,218,'2026-06-18 21:47:46.998214','2026-06-18 21:47:46.998214',NULL,0);
INSERT INTO apartments VALUES(213,'206',2,200000,'occupied',14,219,'2026-06-18 21:47:47.198351','2026-06-18 21:47:47.198351',NULL,0);
INSERT INTO apartments VALUES(214,'207',2,250000,'occupied',14,220,'2026-06-18 21:47:47.396026','2026-06-18 21:47:47.396026',NULL,0);
INSERT INTO apartments VALUES(215,'208',2,120000,'occupied',14,221,'2026-06-18 21:47:47.594925','2026-06-18 21:47:47.594925',NULL,0);
INSERT INTO apartments VALUES(216,'209',2,200000,'occupied',14,222,'2026-06-18 21:47:47.795683','2026-06-18 21:47:47.795683',NULL,0);
INSERT INTO apartments VALUES(217,'210',2,150000,'occupied',14,223,'2026-06-18 21:47:48.003204','2026-06-18 21:47:48.003204',NULL,0);
INSERT INTO apartments VALUES(218,'311',3,150000,'occupied',14,224,'2026-06-18 21:47:48.204015','2026-06-18 21:47:48.204015',NULL,0);
INSERT INTO apartments VALUES(219,'312',3,200000,'occupied',14,225,'2026-06-18 21:47:48.404307','2026-06-18 21:47:48.404307',NULL,0);
INSERT INTO apartments VALUES(220,'313',3,150000,'occupied',14,226,'2026-06-18 21:47:48.604817','2026-06-18 21:47:48.604817',NULL,0);
INSERT INTO apartments VALUES(221,'314',3,150000,'occupied',14,227,'2026-06-18 21:47:48.805729','2026-06-18 21:47:48.805729',NULL,0);
INSERT INTO apartments VALUES(222,'315',3,200000,'occupied',14,228,'2026-06-18 21:47:49.009661','2026-06-18 21:47:49.009661',NULL,0);
INSERT INTO apartments VALUES(223,'416',4,250000,'occupied',14,229,'2026-06-18 21:47:49.208249','2026-06-18 21:47:49.208249',NULL,0);
INSERT INTO apartments VALUES(224,'417',4,250000,'occupied',14,230,'2026-06-18 21:47:49.407866','2026-06-18 21:47:49.407866',NULL,0);
INSERT INTO apartments VALUES(225,'418',4,200000,'occupied',14,231,'2026-06-18 21:47:49.607892','2026-06-18 21:47:49.607892',NULL,0);
INSERT INTO apartments VALUES(226,'419',4,150000,'occupied',14,232,'2026-06-18 21:47:49.806250','2026-06-18 21:47:49.806250',NULL,0);
INSERT INTO apartments VALUES(227,'420',4,120000,'occupied',14,233,'2026-06-18 21:47:50.004967','2026-06-18 21:47:50.004967',NULL,0);
INSERT INTO apartments VALUES(228,'X1',5,300000,'free',14,NULL,'2026-06-18 21:47:50.008006','2026-06-18 21:47:50.008006',NULL,0);
INSERT INTO apartments VALUES(229,'101',1,120000,'occupied',15,234,'2026-06-18 21:47:50.210937','2026-06-18 21:47:50.210937',NULL,0);
INSERT INTO apartments VALUES(230,'102',1,120000,'occupied',15,235,'2026-06-18 21:47:50.410671','2026-06-18 21:47:50.410671',NULL,0);
INSERT INTO apartments VALUES(231,'103',1,200000,'occupied',15,236,'2026-06-18 21:47:50.608734','2026-06-18 21:47:50.608734',NULL,0);
INSERT INTO apartments VALUES(232,'104',1,120000,'occupied',15,237,'2026-06-18 21:47:50.806373','2026-06-18 21:47:50.806373',NULL,0);
INSERT INTO apartments VALUES(233,'105',1,250000,'occupied',15,238,'2026-06-18 21:47:51.006191','2026-06-18 21:47:51.006191',NULL,0);
INSERT INTO apartments VALUES(234,'206',2,250000,'occupied',15,239,'2026-06-18 21:47:51.205057','2026-06-18 21:47:51.205057',NULL,0);
INSERT INTO apartments VALUES(235,'207',2,250000,'occupied',15,240,'2026-06-18 21:47:51.406543','2026-06-18 21:47:51.406543',NULL,0);
INSERT INTO apartments VALUES(236,'208',2,120000,'occupied',15,241,'2026-06-18 21:47:51.618028','2026-06-18 21:47:51.618028',NULL,0);
INSERT INTO apartments VALUES(237,'209',2,120000,'occupied',15,242,'2026-06-18 21:47:51.823913','2026-06-18 21:47:51.823913',NULL,0);
INSERT INTO apartments VALUES(238,'210',2,200000,'occupied',15,243,'2026-06-18 21:47:52.026686','2026-06-18 21:47:52.026686',NULL,0);
INSERT INTO apartments VALUES(239,'311',3,200000,'occupied',15,244,'2026-06-18 21:47:52.230465','2026-06-18 21:47:52.230465',NULL,0);
INSERT INTO apartments VALUES(240,'312',3,250000,'occupied',15,245,'2026-06-18 21:47:52.431920','2026-06-18 21:47:52.431920',NULL,0);
INSERT INTO apartments VALUES(241,'313',3,250000,'occupied',15,246,'2026-06-18 21:47:52.634105','2026-06-18 21:47:52.634105',NULL,0);
INSERT INTO apartments VALUES(242,'314',3,150000,'occupied',15,247,'2026-06-18 21:47:52.834451','2026-06-18 21:47:52.834451',NULL,0);
INSERT INTO apartments VALUES(243,'315',3,120000,'occupied',15,248,'2026-06-18 21:47:53.036170','2026-06-18 21:47:53.036170',NULL,0);
INSERT INTO apartments VALUES(244,'416',4,120000,'occupied',15,249,'2026-06-18 21:47:53.237202','2026-06-18 21:47:53.237202',NULL,0);
INSERT INTO apartments VALUES(245,'417',4,150000,'occupied',15,250,'2026-06-18 21:47:53.436735','2026-06-18 21:47:53.436735',NULL,0);
INSERT INTO apartments VALUES(246,'418',4,120000,'occupied',15,251,'2026-06-18 21:47:53.634499','2026-06-18 21:47:53.634499',NULL,0);
INSERT INTO apartments VALUES(247,'419',4,250000,'occupied',15,252,'2026-06-18 21:47:53.833202','2026-06-18 21:47:53.833202',NULL,0);
INSERT INTO apartments VALUES(248,'420',4,250000,'occupied',15,253,'2026-06-18 21:47:54.044114','2026-06-18 21:47:54.044114',NULL,0);
INSERT INTO apartments VALUES(249,'X1',5,300000,'free',15,NULL,'2026-06-18 21:47:54.047319','2026-06-18 21:47:54.047319',NULL,0);
INSERT INTO apartments VALUES(250,'101',1,200000,'occupied',16,254,'2026-06-18 21:47:54.249378','2026-06-18 21:47:54.249378',NULL,0);
INSERT INTO apartments VALUES(251,'102',1,150000,'occupied',16,255,'2026-06-18 21:47:54.447319','2026-06-18 21:47:54.447319',NULL,0);
INSERT INTO apartments VALUES(252,'103',1,250000,'occupied',16,256,'2026-06-18 21:47:54.656233','2026-06-18 21:47:54.656233',NULL,0);
INSERT INTO apartments VALUES(253,'104',1,250000,'occupied',16,257,'2026-06-18 21:47:54.897563','2026-06-18 21:47:54.897563',NULL,0);
INSERT INTO apartments VALUES(254,'105',1,150000,'occupied',16,258,'2026-06-18 21:47:55.133630','2026-06-18 21:47:55.133630',NULL,0);
INSERT INTO apartments VALUES(255,'206',2,150000,'occupied',16,259,'2026-06-18 21:47:55.353109','2026-06-18 21:47:55.353109',NULL,0);
INSERT INTO apartments VALUES(256,'207',2,250000,'occupied',16,260,'2026-06-18 21:47:55.571110','2026-06-18 21:47:55.571110',NULL,0);
INSERT INTO apartments VALUES(257,'208',2,120000,'occupied',16,261,'2026-06-18 21:47:55.794653','2026-06-18 21:47:55.794653',NULL,0);
INSERT INTO apartments VALUES(258,'209',2,120000,'occupied',16,262,'2026-06-18 21:47:56.007512','2026-06-18 21:47:56.007512',NULL,0);
INSERT INTO apartments VALUES(259,'210',2,150000,'occupied',16,263,'2026-06-18 21:47:56.226017','2026-06-18 21:47:56.226017',NULL,0);
INSERT INTO apartments VALUES(260,'311',3,200000,'occupied',16,264,'2026-06-18 21:47:56.437197','2026-06-18 21:47:56.437197',NULL,0);
INSERT INTO apartments VALUES(261,'312',3,250000,'occupied',16,265,'2026-06-18 21:47:56.644653','2026-06-18 21:47:56.644653',NULL,0);
INSERT INTO apartments VALUES(262,'313',3,200000,'occupied',16,266,'2026-06-18 21:47:56.854026','2026-06-18 21:47:56.854026',NULL,0);
INSERT INTO apartments VALUES(263,'314',3,200000,'occupied',16,267,'2026-06-18 21:47:57.062988','2026-06-18 21:47:57.062988',NULL,0);
INSERT INTO apartments VALUES(264,'315',3,120000,'occupied',16,268,'2026-06-18 21:47:57.278164','2026-06-18 21:47:57.278164',NULL,0);
INSERT INTO apartments VALUES(265,'416',4,200000,'occupied',16,269,'2026-06-18 21:47:57.482738','2026-06-18 21:47:57.482738',NULL,0);
INSERT INTO apartments VALUES(266,'417',4,200000,'occupied',16,270,'2026-06-18 21:47:57.687795','2026-06-18 21:47:57.687795',NULL,0);
INSERT INTO apartments VALUES(267,'418',4,250000,'occupied',16,271,'2026-06-18 21:47:57.895506','2026-06-18 21:47:57.895506',NULL,0);
INSERT INTO apartments VALUES(268,'419',4,120000,'occupied',16,272,'2026-06-18 21:47:58.109815','2026-06-18 21:47:58.109815',NULL,0);
INSERT INTO apartments VALUES(269,'420',4,150000,'occupied',16,273,'2026-06-18 21:47:58.315634','2026-06-18 21:47:58.315634',NULL,0);
INSERT INTO apartments VALUES(270,'X1',5,300000,'free',16,NULL,'2026-06-18 21:47:58.319203','2026-06-18 21:47:58.319203',NULL,0);
INSERT INTO apartments VALUES(271,'1 RDC',0,160000,'free',17,NULL,'2026-06-19 15:49:11.388138','2026-06-19 15:49:11.388138',NULL,0);
INSERT INTO apartments VALUES(272,'2 RDC',0,120000,'free',17,NULL,'2026-06-19 15:49:28.916115','2026-06-19 15:49:28.916115',NULL,0);
INSERT INTO apartments VALUES(273,'3',1,200000,'free',17,NULL,'2026-06-19 15:49:43.953867','2026-06-19 15:49:43.953867',NULL,0);
INSERT INTO apartments VALUES(274,'A',0,90000,'free',18,NULL,'2026-06-20 08:04:36.600319','2026-06-20 08:04:36.600319',NULL,0);
INSERT INTO apartments VALUES(275,'B',0,100000,'free',18,NULL,'2026-06-20 08:04:46.319911','2026-06-20 08:04:46.319911',NULL,0);
CREATE TABLE IF NOT EXISTS "payments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "amount" decimal(10,2) NOT NULL, "paid_at" date, "due_date" date NOT NULL, "status" varchar DEFAULT 'pending' NOT NULL, "month" integer NOT NULL, "year" integer NOT NULL, "reference" varchar, "apartment_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "proof" varchar, "payment_method" varchar DEFAULT NULL, CONSTRAINT "fk_rails_73a62ad939"
FOREIGN KEY ("apartment_id")
  REFERENCES "apartments" ("id")
, CONSTRAINT "fk_rails_37fe743ccd"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
INSERT INTO payments VALUES(136,120000,'2026-06-21','2026-06-12','paid',6,2026,'PAY-202606-145-154',145,154,'2026-06-18 21:47:33.673322','2026-06-21 07:05:24.079175','/uploads/proof_1782025473_8ab7c0a4.jpeg',NULL);
INSERT INTO payments VALUES(137,250000,'2026-06-21','2026-06-12','paid',6,2026,'PAY-202606-146-155',146,155,'2026-06-18 21:47:33.877506','2026-06-21 07:54:19.533171','/uploads/proof_1782027598_ca82154b.jpeg',NULL);
INSERT INTO payments VALUES(138,150000,'2026-06-22','2026-06-12','paid',6,2026,NULL,147,156,'2026-06-18 21:47:34.092023','2026-06-22 09:49:33.712775',NULL,'cash');
INSERT INTO payments VALUES(139,200000,'2026-06-22','2026-06-12','paid',6,2026,NULL,148,157,'2026-06-18 21:47:34.307552','2026-06-22 09:52:21.168903',NULL,'cash');
INSERT INTO payments VALUES(140,200000,'2026-06-22','2026-06-12','paid',6,2026,NULL,149,158,'2026-06-18 21:47:34.519684','2026-06-22 09:53:29.207649',NULL,'cash');
INSERT INTO payments VALUES(141,250000,NULL,'2026-06-12','paid',6,2026,NULL,150,159,'2026-06-18 21:47:34.736171','2026-06-18 21:47:34.736171',NULL,NULL);
INSERT INTO payments VALUES(142,120000,NULL,'2026-06-12','paid',6,2026,NULL,151,160,'2026-06-18 21:47:34.941970','2026-06-18 21:47:34.941970',NULL,NULL);
INSERT INTO payments VALUES(143,120000,NULL,'2026-06-12','paid',6,2026,NULL,152,161,'2026-06-18 21:47:35.150601','2026-06-18 21:47:35.150601',NULL,NULL);
INSERT INTO payments VALUES(144,120000,NULL,'2026-06-12','paid',6,2026,NULL,153,162,'2026-06-18 21:47:35.376325','2026-06-18 21:47:35.376325',NULL,NULL);
INSERT INTO payments VALUES(145,250000,NULL,'2026-06-12','paid',6,2026,NULL,154,163,'2026-06-18 21:47:35.581166','2026-06-18 21:47:35.581166',NULL,NULL);
INSERT INTO payments VALUES(146,250000,'2026-06-22','2026-06-12','paid',6,2026,NULL,155,164,'2026-06-18 21:47:35.783989','2026-06-22 09:53:46.400562',NULL,'cash');
INSERT INTO payments VALUES(147,120000,'2026-06-22','2026-06-12','paid',6,2026,NULL,156,165,'2026-06-18 21:47:36.010087','2026-06-22 09:54:03.740664',NULL,'cash');
INSERT INTO payments VALUES(148,200000,NULL,'2026-06-12','paid',6,2026,NULL,157,166,'2026-06-18 21:47:36.226083','2026-06-18 21:47:36.226083',NULL,NULL);
INSERT INTO payments VALUES(149,150000,NULL,'2026-06-12','paid',6,2026,NULL,158,167,'2026-06-18 21:47:36.443168','2026-06-18 21:47:36.443168',NULL,NULL);
INSERT INTO payments VALUES(150,150000,NULL,'2026-06-12','paid',6,2026,NULL,159,168,'2026-06-18 21:47:36.663009','2026-06-18 21:47:36.663009',NULL,NULL);
INSERT INTO payments VALUES(151,250000,'2026-06-22','2026-06-12','paid',6,2026,NULL,160,169,'2026-06-18 21:47:36.863549','2026-06-22 09:55:51.379233',NULL,'cash');
INSERT INTO payments VALUES(152,200000,NULL,'2026-06-12','pending',6,2026,NULL,161,170,'2026-06-18 21:47:37.067643','2026-06-18 21:47:37.067643',NULL,NULL);
INSERT INTO payments VALUES(153,200000,NULL,'2026-06-12','pending',6,2026,NULL,162,171,'2026-06-18 21:47:37.276384','2026-06-18 21:47:37.276384',NULL,NULL);
INSERT INTO payments VALUES(154,250000,NULL,'2026-06-12','paid',6,2026,NULL,163,172,'2026-06-18 21:47:37.476698','2026-06-18 21:47:37.476698',NULL,NULL);
INSERT INTO payments VALUES(155,200000,NULL,'2026-06-12','pending',6,2026,NULL,164,173,'2026-06-18 21:47:37.687334','2026-06-18 21:47:37.687334',NULL,NULL);
INSERT INTO payments VALUES(156,250000,NULL,'2026-06-12','late',6,2026,NULL,166,174,'2026-06-18 21:47:37.910301','2026-06-18 21:47:37.910301',NULL,NULL);
INSERT INTO payments VALUES(157,150000,NULL,'2026-06-12','late',6,2026,NULL,167,175,'2026-06-18 21:47:38.119740','2026-06-18 21:47:38.119740',NULL,NULL);
INSERT INTO payments VALUES(158,150000,NULL,'2026-06-12','paid',6,2026,NULL,168,176,'2026-06-18 21:47:38.332906','2026-06-18 21:47:38.332906',NULL,NULL);
INSERT INTO payments VALUES(159,200000,NULL,'2026-06-12','pending',6,2026,NULL,169,177,'2026-06-18 21:47:38.535361','2026-06-18 21:47:38.535361',NULL,NULL);
INSERT INTO payments VALUES(160,120000,NULL,'2026-06-12','paid',6,2026,NULL,170,178,'2026-06-18 21:47:38.745254','2026-06-18 21:47:38.745254',NULL,NULL);
INSERT INTO payments VALUES(161,250000,NULL,'2026-06-12','late',6,2026,NULL,171,179,'2026-06-18 21:47:38.962202','2026-06-18 21:47:38.962202',NULL,NULL);
INSERT INTO payments VALUES(162,200000,NULL,'2026-06-12','late',6,2026,NULL,172,180,'2026-06-18 21:47:39.185050','2026-06-18 21:47:39.185050',NULL,NULL);
INSERT INTO payments VALUES(163,200000,NULL,'2026-06-12','late',6,2026,NULL,173,181,'2026-06-18 21:47:39.403548','2026-06-18 21:47:39.403548',NULL,NULL);
INSERT INTO payments VALUES(164,120000,NULL,'2026-06-12','pending',6,2026,NULL,174,182,'2026-06-18 21:47:39.622641','2026-06-18 21:47:39.622641',NULL,NULL);
INSERT INTO payments VALUES(165,150000,NULL,'2026-06-12','late',6,2026,NULL,175,183,'2026-06-18 21:47:39.840720','2026-06-18 21:47:39.840720',NULL,NULL);
INSERT INTO payments VALUES(166,150000,NULL,'2026-06-12','pending',6,2026,NULL,176,184,'2026-06-18 21:47:40.042835','2026-06-18 21:47:40.042835',NULL,NULL);
INSERT INTO payments VALUES(167,120000,NULL,'2026-06-12','paid',6,2026,NULL,177,185,'2026-06-18 21:47:40.242863','2026-06-18 21:47:40.242863',NULL,NULL);
INSERT INTO payments VALUES(168,150000,NULL,'2026-06-12','late',6,2026,NULL,178,186,'2026-06-18 21:47:40.449063','2026-06-18 21:47:40.449063',NULL,NULL);
INSERT INTO payments VALUES(169,150000,NULL,'2026-06-12','paid',6,2026,NULL,179,187,'2026-06-18 21:47:40.654274','2026-06-18 21:47:40.654274',NULL,NULL);
INSERT INTO payments VALUES(170,200000,NULL,'2026-06-12','pending',6,2026,NULL,180,188,'2026-06-18 21:47:40.858883','2026-06-18 21:47:40.858883',NULL,NULL);
INSERT INTO payments VALUES(171,250000,NULL,'2026-06-12','pending',6,2026,NULL,181,189,'2026-06-18 21:47:41.058430','2026-06-18 21:47:41.058430',NULL,NULL);
INSERT INTO payments VALUES(172,150000,NULL,'2026-06-12','late',6,2026,NULL,182,190,'2026-06-18 21:47:41.257893','2026-06-18 21:47:41.257893',NULL,NULL);
INSERT INTO payments VALUES(173,120000,NULL,'2026-06-12','paid',6,2026,NULL,183,191,'2026-06-18 21:47:41.457519','2026-06-18 21:47:41.457519',NULL,NULL);
INSERT INTO payments VALUES(174,200000,NULL,'2026-06-12','paid',6,2026,NULL,184,192,'2026-06-18 21:47:41.665207','2026-06-18 21:47:41.665207',NULL,NULL);
INSERT INTO payments VALUES(175,250000,NULL,'2026-06-12','late',6,2026,NULL,185,193,'2026-06-18 21:47:41.867408','2026-06-18 21:47:41.867408',NULL,NULL);
INSERT INTO payments VALUES(176,200000,NULL,'2026-06-12','paid',6,2026,NULL,187,194,'2026-06-18 21:47:42.080014','2026-06-18 21:47:42.080014',NULL,NULL);
INSERT INTO payments VALUES(177,200000,NULL,'2026-06-12','paid',6,2026,NULL,188,195,'2026-06-18 21:47:42.300134','2026-06-18 21:47:42.300134',NULL,NULL);
INSERT INTO payments VALUES(178,200000,NULL,'2026-06-12','paid',6,2026,NULL,189,196,'2026-06-18 21:47:42.519974','2026-06-18 21:47:42.519974',NULL,NULL);
INSERT INTO payments VALUES(179,200000,NULL,'2026-06-12','pending',6,2026,NULL,190,197,'2026-06-18 21:47:42.726606','2026-06-18 21:47:42.726606',NULL,NULL);
INSERT INTO payments VALUES(180,120000,NULL,'2026-06-12','paid',6,2026,NULL,191,198,'2026-06-18 21:47:42.928794','2026-06-18 21:47:42.928794',NULL,NULL);
INSERT INTO payments VALUES(181,200000,NULL,'2026-06-12','pending',6,2026,NULL,192,199,'2026-06-18 21:47:43.134137','2026-06-18 21:47:43.134137',NULL,NULL);
INSERT INTO payments VALUES(182,150000,NULL,'2026-06-12','late',6,2026,NULL,193,200,'2026-06-18 21:47:43.270571','2026-06-18 21:47:43.270571',NULL,NULL);
INSERT INTO payments VALUES(183,120000,NULL,'2026-06-12','paid',6,2026,NULL,194,201,'2026-06-18 21:47:43.497134','2026-06-18 21:47:43.497134',NULL,NULL);
INSERT INTO payments VALUES(184,120000,NULL,'2026-06-12','late',6,2026,NULL,195,202,'2026-06-18 21:47:43.715762','2026-06-18 21:47:43.715762',NULL,NULL);
INSERT INTO payments VALUES(185,120000,NULL,'2026-06-12','paid',6,2026,NULL,196,203,'2026-06-18 21:47:43.922479','2026-06-18 21:47:43.922479',NULL,NULL);
INSERT INTO payments VALUES(186,250000,NULL,'2026-06-12','paid',6,2026,NULL,197,204,'2026-06-18 21:47:44.122737','2026-06-18 21:47:44.122737',NULL,NULL);
INSERT INTO payments VALUES(187,250000,NULL,'2026-06-12','pending',6,2026,NULL,198,205,'2026-06-18 21:47:44.325777','2026-06-18 21:47:44.325777',NULL,NULL);
INSERT INTO payments VALUES(188,120000,NULL,'2026-06-12','paid',6,2026,NULL,199,206,'2026-06-18 21:47:44.526549','2026-06-18 21:47:44.526549',NULL,NULL);
INSERT INTO payments VALUES(189,120000,NULL,'2026-06-12','pending',6,2026,NULL,200,207,'2026-06-18 21:47:44.733731','2026-06-18 21:47:44.733731',NULL,NULL);
INSERT INTO payments VALUES(190,200000,NULL,'2026-06-12','pending',6,2026,NULL,201,208,'2026-06-18 21:47:44.941000','2026-06-18 21:47:44.941000',NULL,NULL);
INSERT INTO payments VALUES(191,200000,NULL,'2026-06-12','paid',6,2026,NULL,202,209,'2026-06-18 21:47:45.154321','2026-06-18 21:47:45.154321',NULL,NULL);
INSERT INTO payments VALUES(192,250000,NULL,'2026-06-12','pending',6,2026,NULL,203,210,'2026-06-18 21:47:45.359505','2026-06-18 21:47:45.359505',NULL,NULL);
INSERT INTO payments VALUES(193,250000,NULL,'2026-06-12','pending',6,2026,NULL,204,211,'2026-06-18 21:47:45.561315','2026-06-18 21:47:45.561315',NULL,NULL);
INSERT INTO payments VALUES(194,150000,NULL,'2026-06-12','late',6,2026,NULL,205,212,'2026-06-18 21:47:45.764974','2026-06-18 21:47:45.764974',NULL,NULL);
INSERT INTO payments VALUES(195,150000,NULL,'2026-06-12','paid',6,2026,NULL,206,213,'2026-06-18 21:47:45.971822','2026-06-18 21:47:45.971822',NULL,NULL);
INSERT INTO payments VALUES(196,150000,NULL,'2026-06-12','late',6,2026,NULL,208,214,'2026-06-18 21:47:46.188688','2026-06-18 21:47:46.188688',NULL,NULL);
INSERT INTO payments VALUES(197,250000,NULL,'2026-06-12','paid',6,2026,NULL,209,215,'2026-06-18 21:47:46.390016','2026-06-18 21:47:46.390016',NULL,NULL);
INSERT INTO payments VALUES(198,150000,NULL,'2026-06-12','paid',6,2026,NULL,210,216,'2026-06-18 21:47:46.591497','2026-06-18 21:47:46.591497',NULL,NULL);
INSERT INTO payments VALUES(199,250000,NULL,'2026-06-12','late',6,2026,NULL,211,217,'2026-06-18 21:47:46.795579','2026-06-18 21:47:46.795579',NULL,NULL);
INSERT INTO payments VALUES(200,250000,NULL,'2026-06-12','paid',6,2026,NULL,212,218,'2026-06-18 21:47:46.999119','2026-06-18 21:47:46.999119',NULL,NULL);
INSERT INTO payments VALUES(201,200000,NULL,'2026-06-12','paid',6,2026,NULL,213,219,'2026-06-18 21:47:47.199300','2026-06-18 21:47:47.199300',NULL,NULL);
INSERT INTO payments VALUES(202,250000,NULL,'2026-06-12','paid',6,2026,NULL,214,220,'2026-06-18 21:47:47.396884','2026-06-18 21:47:47.396884',NULL,NULL);
INSERT INTO payments VALUES(203,120000,NULL,'2026-06-12','late',6,2026,NULL,215,221,'2026-06-18 21:47:47.595845','2026-06-18 21:47:47.595845',NULL,NULL);
INSERT INTO payments VALUES(204,200000,NULL,'2026-06-12','paid',6,2026,NULL,216,222,'2026-06-18 21:47:47.796628','2026-06-18 21:47:47.796628',NULL,NULL);
INSERT INTO payments VALUES(205,150000,NULL,'2026-06-12','late',6,2026,NULL,217,223,'2026-06-18 21:47:48.004065','2026-06-18 21:47:48.004065',NULL,NULL);
INSERT INTO payments VALUES(206,150000,NULL,'2026-06-12','paid',6,2026,NULL,218,224,'2026-06-18 21:47:48.204918','2026-06-18 21:47:48.204918',NULL,NULL);
INSERT INTO payments VALUES(207,200000,NULL,'2026-06-12','late',6,2026,NULL,219,225,'2026-06-18 21:47:48.405177','2026-06-18 21:47:48.405177',NULL,NULL);
INSERT INTO payments VALUES(208,150000,NULL,'2026-06-12','pending',6,2026,NULL,220,226,'2026-06-18 21:47:48.605669','2026-06-18 21:47:48.605669',NULL,NULL);
INSERT INTO payments VALUES(209,150000,NULL,'2026-06-12','late',6,2026,NULL,221,227,'2026-06-18 21:47:48.806770','2026-06-18 21:47:48.806770',NULL,NULL);
INSERT INTO payments VALUES(210,200000,NULL,'2026-06-12','paid',6,2026,NULL,222,228,'2026-06-18 21:47:49.010618','2026-06-18 21:47:49.010618',NULL,NULL);
INSERT INTO payments VALUES(211,250000,NULL,'2026-06-12','late',6,2026,NULL,223,229,'2026-06-18 21:47:49.209497','2026-06-18 21:47:49.209497',NULL,NULL);
INSERT INTO payments VALUES(212,250000,NULL,'2026-06-12','late',6,2026,NULL,224,230,'2026-06-18 21:47:49.409204','2026-06-18 21:47:49.409204',NULL,NULL);
INSERT INTO payments VALUES(213,200000,NULL,'2026-06-12','late',6,2026,NULL,225,231,'2026-06-18 21:47:49.609132','2026-06-18 21:47:49.609132',NULL,NULL);
INSERT INTO payments VALUES(214,150000,NULL,'2026-06-12','paid',6,2026,NULL,226,232,'2026-06-18 21:47:49.807183','2026-06-18 21:47:49.807183',NULL,NULL);
INSERT INTO payments VALUES(215,120000,NULL,'2026-06-12','pending',6,2026,NULL,227,233,'2026-06-18 21:47:50.005869','2026-06-18 21:47:50.005869',NULL,NULL);
INSERT INTO payments VALUES(216,120000,NULL,'2026-06-12','late',6,2026,NULL,229,234,'2026-06-18 21:47:50.211818','2026-06-18 21:47:50.211818',NULL,NULL);
INSERT INTO payments VALUES(217,120000,NULL,'2026-06-12','late',6,2026,NULL,230,235,'2026-06-18 21:47:50.411569','2026-06-18 21:47:50.411569',NULL,NULL);
INSERT INTO payments VALUES(218,200000,NULL,'2026-06-12','late',6,2026,NULL,231,236,'2026-06-18 21:47:50.609972','2026-06-18 21:47:50.609972',NULL,NULL);
INSERT INTO payments VALUES(219,120000,NULL,'2026-06-12','late',6,2026,NULL,232,237,'2026-06-18 21:47:50.807307','2026-06-18 21:47:50.807307',NULL,NULL);
INSERT INTO payments VALUES(220,250000,NULL,'2026-06-12','paid',6,2026,NULL,233,238,'2026-06-18 21:47:51.007094','2026-06-18 21:47:51.007094',NULL,NULL);
INSERT INTO payments VALUES(221,250000,NULL,'2026-06-12','late',6,2026,NULL,234,239,'2026-06-18 21:47:51.205916','2026-06-18 21:47:51.205916',NULL,NULL);
INSERT INTO payments VALUES(222,250000,NULL,'2026-06-12','pending',6,2026,NULL,235,240,'2026-06-18 21:47:51.407425','2026-06-18 21:47:51.407425',NULL,NULL);
INSERT INTO payments VALUES(223,120000,NULL,'2026-06-12','paid',6,2026,NULL,236,241,'2026-06-18 21:47:51.619029','2026-06-18 21:47:51.619029',NULL,NULL);
INSERT INTO payments VALUES(224,120000,NULL,'2026-06-12','paid',6,2026,NULL,237,242,'2026-06-18 21:47:51.824891','2026-06-18 21:47:51.824891',NULL,NULL);
INSERT INTO payments VALUES(225,200000,NULL,'2026-06-12','pending',6,2026,NULL,238,243,'2026-06-18 21:47:52.027644','2026-06-18 21:47:52.027644',NULL,NULL);
INSERT INTO payments VALUES(226,200000,NULL,'2026-06-12','paid',6,2026,NULL,239,244,'2026-06-18 21:47:52.231316','2026-06-18 21:47:52.231316',NULL,NULL);
INSERT INTO payments VALUES(227,250000,NULL,'2026-06-12','paid',6,2026,NULL,240,245,'2026-06-18 21:47:52.432837','2026-06-18 21:47:52.432837',NULL,NULL);
INSERT INTO payments VALUES(228,250000,NULL,'2026-06-12','paid',6,2026,NULL,241,246,'2026-06-18 21:47:52.635271','2026-06-18 21:47:52.635271',NULL,NULL);
INSERT INTO payments VALUES(229,150000,NULL,'2026-06-12','pending',6,2026,NULL,242,247,'2026-06-18 21:47:52.835452','2026-06-18 21:47:52.835452',NULL,NULL);
INSERT INTO payments VALUES(230,120000,NULL,'2026-06-12','late',6,2026,NULL,243,248,'2026-06-18 21:47:53.037215','2026-06-18 21:47:53.037215',NULL,NULL);
INSERT INTO payments VALUES(231,120000,NULL,'2026-06-12','pending',6,2026,NULL,244,249,'2026-06-18 21:47:53.238096','2026-06-18 21:47:53.238096',NULL,NULL);
INSERT INTO payments VALUES(232,150000,NULL,'2026-06-12','paid',6,2026,NULL,245,250,'2026-06-18 21:47:53.437652','2026-06-18 21:47:53.437652',NULL,NULL);
INSERT INTO payments VALUES(233,120000,NULL,'2026-06-12','late',6,2026,NULL,246,251,'2026-06-18 21:47:53.635472','2026-06-18 21:47:53.635472',NULL,NULL);
INSERT INTO payments VALUES(234,250000,NULL,'2026-06-12','late',6,2026,NULL,247,252,'2026-06-18 21:47:53.834492','2026-06-18 21:47:53.834492',NULL,NULL);
INSERT INTO payments VALUES(235,250000,NULL,'2026-06-12','late',6,2026,NULL,248,253,'2026-06-18 21:47:54.045112','2026-06-18 21:47:54.045112',NULL,NULL);
INSERT INTO payments VALUES(236,200000,NULL,'2026-06-12','paid',6,2026,NULL,250,254,'2026-06-18 21:47:54.250465','2026-06-18 21:47:54.250465',NULL,NULL);
INSERT INTO payments VALUES(237,150000,NULL,'2026-06-12','paid',6,2026,NULL,251,255,'2026-06-18 21:47:54.448269','2026-06-18 21:47:54.448269',NULL,NULL);
INSERT INTO payments VALUES(238,250000,NULL,'2026-06-12','pending',6,2026,NULL,252,256,'2026-06-18 21:47:54.657172','2026-06-18 21:47:54.657172',NULL,NULL);
INSERT INTO payments VALUES(239,250000,NULL,'2026-06-12','late',6,2026,NULL,253,257,'2026-06-18 21:47:54.899708','2026-06-18 21:47:54.899708',NULL,NULL);
INSERT INTO payments VALUES(240,150000,NULL,'2026-06-12','paid',6,2026,NULL,254,258,'2026-06-18 21:47:55.134955','2026-06-18 21:47:55.134955',NULL,NULL);
INSERT INTO payments VALUES(241,150000,NULL,'2026-06-12','pending',6,2026,NULL,255,259,'2026-06-18 21:47:55.354286','2026-06-18 21:47:55.354286',NULL,NULL);
INSERT INTO payments VALUES(242,250000,NULL,'2026-06-12','paid',6,2026,NULL,256,260,'2026-06-18 21:47:55.572656','2026-06-18 21:47:55.572656',NULL,NULL);
INSERT INTO payments VALUES(243,120000,NULL,'2026-06-12','paid',6,2026,NULL,257,261,'2026-06-18 21:47:55.795826','2026-06-18 21:47:55.795826',NULL,NULL);
INSERT INTO payments VALUES(244,120000,NULL,'2026-06-12','late',6,2026,NULL,258,262,'2026-06-18 21:47:56.009060','2026-06-18 21:47:56.009060',NULL,NULL);
INSERT INTO payments VALUES(245,150000,NULL,'2026-06-12','pending',6,2026,NULL,259,263,'2026-06-18 21:47:56.227808','2026-06-18 21:47:56.227808',NULL,NULL);
INSERT INTO payments VALUES(246,200000,NULL,'2026-06-12','late',6,2026,NULL,260,264,'2026-06-18 21:47:56.438206','2026-06-18 21:47:56.438206',NULL,NULL);
INSERT INTO payments VALUES(247,250000,NULL,'2026-06-12','late',6,2026,NULL,261,265,'2026-06-18 21:47:56.646462','2026-06-18 21:47:56.646462',NULL,NULL);
INSERT INTO payments VALUES(248,200000,NULL,'2026-06-12','paid',6,2026,NULL,262,266,'2026-06-18 21:47:56.855028','2026-06-18 21:47:56.855028',NULL,NULL);
INSERT INTO payments VALUES(249,200000,NULL,'2026-06-12','paid',6,2026,NULL,263,267,'2026-06-18 21:47:57.063992','2026-06-18 21:47:57.063992',NULL,NULL);
INSERT INTO payments VALUES(250,120000,NULL,'2026-06-12','pending',6,2026,NULL,264,268,'2026-06-18 21:47:57.279076','2026-06-18 21:47:57.279076',NULL,NULL);
INSERT INTO payments VALUES(251,200000,NULL,'2026-06-12','pending',6,2026,NULL,265,269,'2026-06-18 21:47:57.483851','2026-06-18 21:47:57.483851',NULL,NULL);
INSERT INTO payments VALUES(252,200000,NULL,'2026-06-12','late',6,2026,NULL,266,270,'2026-06-18 21:47:57.688713','2026-06-18 21:47:57.688713',NULL,NULL);
INSERT INTO payments VALUES(253,250000,NULL,'2026-06-12','pending',6,2026,NULL,267,271,'2026-06-18 21:47:57.896467','2026-06-18 21:47:57.896467',NULL,NULL);
INSERT INTO payments VALUES(254,120000,NULL,'2026-06-12','late',6,2026,NULL,268,272,'2026-06-18 21:47:58.110969','2026-06-18 21:47:58.110969',NULL,NULL);
INSERT INTO payments VALUES(255,150000,NULL,'2026-06-12','pending',6,2026,NULL,269,273,'2026-06-18 21:47:58.316660','2026-06-18 21:47:58.316660',NULL,NULL);
INSERT INTO payments VALUES(256,300000,'2026-06-18','2026-06-12','paid',6,2026,'PAY-202606-207-275',207,275,'2026-06-18 21:55:01.741905','2026-06-18 22:23:18.609858',NULL,NULL);
CREATE TABLE IF NOT EXISTS "publications" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "content" text NOT NULL, "building_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "likes_count" integer DEFAULT 0 NOT NULL, "comments_count" integer DEFAULT 0 NOT NULL, CONSTRAINT "fk_rails_8d10004933"
FOREIGN KEY ("building_id")
  REFERENCES "buildings" ("id")
, CONSTRAINT "fk_rails_cf498aa521"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
INSERT INTO publications VALUES(3,unistr('Bonjour, je m''appelle Der, je suis votre nouveau voisin.\u000d\u000aBonne journée'),13,275,'2026-06-18 22:15:30.867565','2026-06-18 22:15:30.867565',1,1);
INSERT INTO publications VALUES(4,'Hello les voisins',12,277,'2026-06-19 07:42:49.315938','2026-06-19 07:42:49.315938',1,0);
INSERT INTO publications VALUES(5,'Merçi de vérifier vos salles de bain',12,152,'2026-06-19 07:53:31.152969','2026-06-19 07:53:31.152969',0,0);
CREATE TABLE IF NOT EXISTS "move_out_notices" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "move_out_date" date NOT NULL, "apartment_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_538f86e910"
FOREIGN KEY ("apartment_id")
  REFERENCES "apartments" ("id")
, CONSTRAINT "fk_rails_746c66b351"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
);
INSERT INTO move_out_notices VALUES(1,'2026-07-23',207,275,'2026-06-18 22:22:49.435307','2026-06-18 22:22:49.435307');
CREATE TABLE IF NOT EXISTS "likes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "publication_id" integer NOT NULL, "user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c5db1cc33f"
FOREIGN KEY ("publication_id")
  REFERENCES "publications" ("id")
, CONSTRAINT "fk_rails_1e09b5dabf"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
INSERT INTO likes VALUES(1,3,152,'2026-06-18 22:21:57.057254','2026-06-18 22:21:57.057254');
INSERT INTO likes VALUES(2,4,152,'2026-06-19 07:44:00.797299','2026-06-19 07:44:00.797299');
CREATE TABLE IF NOT EXISTS "comments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "publication_id" integer NOT NULL, "user_id" integer NOT NULL, "content" text NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_6be1db031f"
FOREIGN KEY ("publication_id")
  REFERENCES "publications" ("id")
, CONSTRAINT "fk_rails_03de2dc08c"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
INSERT INTO comments VALUES(1,3,152,'Bon arrivé M. Der','2026-06-18 22:22:18.311618','2026-06-18 22:22:18.311618');
CREATE TABLE IF NOT EXISTS "providers" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar NOT NULL, "last_name" varchar NOT NULL, "phone" varchar NOT NULL, "trade" varchar NOT NULL, "agency_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c8e9781280"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
INSERT INTO providers VALUES(1,'Babacar','Ndao','771234567','plombier',12,'2026-06-20 20:29:27.125105','2026-06-20 20:29:27.125105');
CREATE TABLE IF NOT EXISTS "incidents" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar NOT NULL, "description" text NOT NULL, "status" varchar DEFAULT 'open' NOT NULL, "apartment_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "provider_id" integer, CONSTRAINT "fk_rails_6e72ca0e49"
FOREIGN KEY ("tenant_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_a51d50c7bc"
FOREIGN KEY ("apartment_id")
  REFERENCES "apartments" ("id")
, CONSTRAINT "fk_rails_aee7a62715"
FOREIGN KEY ("provider_id")
  REFERENCES "providers" ("id")
);
INSERT INTO incidents VALUES(2,'Cuisine','Il n''y a pas de placard dans la cuisne','resolved',207,275,'2026-06-18 22:24:59.806723','2026-06-20 20:11:36.639625',NULL);
INSERT INTO incidents VALUES(3,'Fenêtres','La fenetre de la cuisin est défectueuse','open',166,277,'2026-06-19 07:43:33.063580','2026-06-19 07:43:33.063580',NULL);
INSERT INTO incidents VALUES(4,'Surpresseur','Le surpresseur est défectueux','in_progress',207,275,'2026-06-20 20:07:40.128866','2026-06-20 21:13:06.299500',1);
CREATE TABLE IF NOT EXISTS "permissions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "resource" varchar NOT NULL, "action" varchar NOT NULL, "description" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "roles" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "agency_id" integer, "description" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_1fc3d10048"
FOREIGN KEY ("agency_id")
  REFERENCES "agencies" ("id")
);
INSERT INTO roles VALUES(1,'Agent recouvrement',12,'Charger de ....','2026-06-21 09:20:59.525666','2026-06-21 09:20:59.525666');
INSERT INTO roles VALUES(2,'Superviseur',12,'','2026-06-21 09:21:14.949937','2026-06-21 09:21:14.949937');
INSERT INTO roles VALUES(3,'Manager',12,'','2026-06-21 09:30:20.398510','2026-06-21 09:30:20.398510');
CREATE TABLE IF NOT EXISTS "role_permissions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "role_id" integer NOT NULL, "permission_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_60126080bd"
FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id")
, CONSTRAINT "fk_rails_439e640a3f"
FOREIGN KEY ("permission_id")
  REFERENCES "permissions" ("id")
);
CREATE TABLE IF NOT EXISTS "user_roles" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "role_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_318345354e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_3369e0d5fc"
FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id")
);
INSERT INTO sqlite_sequence VALUES('users',279);
INSERT INTO sqlite_sequence VALUES('agencies',14);
INSERT INTO sqlite_sequence VALUES('owners',17);
INSERT INTO sqlite_sequence VALUES('buildings',18);
INSERT INTO sqlite_sequence VALUES('apartments',275);
INSERT INTO sqlite_sequence VALUES('payments',256);
INSERT INTO sqlite_sequence VALUES('publications',5);
INSERT INTO sqlite_sequence VALUES('likes',2);
INSERT INTO sqlite_sequence VALUES('comments',1);
INSERT INTO sqlite_sequence VALUES('move_out_notices',1);
INSERT INTO sqlite_sequence VALUES('providers',1);
INSERT INTO sqlite_sequence VALUES('incidents',4);
INSERT INTO sqlite_sequence VALUES('roles',3);
CREATE INDEX "index_users_on_agency_id" ON "users" ("agency_id");
CREATE INDEX "index_users_on_building_id" ON "users" ("building_id");
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_phone" ON "users" ("phone");
CREATE INDEX "index_owners_on_agency_id" ON "owners" ("agency_id");
CREATE INDEX "index_buildings_on_owner_id" ON "buildings" ("owner_id");
CREATE INDEX "index_buildings_on_agency_id" ON "buildings" ("agency_id");
CREATE INDEX "index_apartments_on_building_id" ON "apartments" ("building_id");
CREATE INDEX "index_apartments_on_tenant_id" ON "apartments" ("tenant_id");
CREATE UNIQUE INDEX "index_apartments_on_building_id_and_number" ON "apartments" ("building_id", "number");
CREATE INDEX "index_payments_on_apartment_id" ON "payments" ("apartment_id");
CREATE INDEX "index_payments_on_tenant_id" ON "payments" ("tenant_id");
CREATE UNIQUE INDEX "index_payments_on_apartment_id_and_month_and_year" ON "payments" ("apartment_id", "month", "year");
CREATE INDEX "index_publications_on_building_id" ON "publications" ("building_id");
CREATE INDEX "index_publications_on_tenant_id" ON "publications" ("tenant_id");
CREATE INDEX "index_move_out_notices_on_apartment_id" ON "move_out_notices" ("apartment_id");
CREATE INDEX "index_move_out_notices_on_tenant_id" ON "move_out_notices" ("tenant_id");
CREATE INDEX "index_likes_on_publication_id" ON "likes" ("publication_id");
CREATE INDEX "index_likes_on_user_id" ON "likes" ("user_id");
CREATE UNIQUE INDEX "index_likes_on_publication_id_and_user_id" ON "likes" ("publication_id", "user_id");
CREATE INDEX "index_comments_on_publication_id" ON "comments" ("publication_id");
CREATE INDEX "index_comments_on_user_id" ON "comments" ("user_id");
CREATE INDEX "index_providers_on_agency_id" ON "providers" ("agency_id");
CREATE INDEX "index_incidents_on_apartment_id" ON "incidents" ("apartment_id");
CREATE INDEX "index_incidents_on_tenant_id" ON "incidents" ("tenant_id");
CREATE INDEX "index_incidents_on_provider_id" ON "incidents" ("provider_id");
CREATE UNIQUE INDEX "index_permissions_on_resource_and_action" ON "permissions" ("resource", "action");
CREATE INDEX "index_roles_on_agency_id" ON "roles" ("agency_id");
CREATE UNIQUE INDEX "index_roles_on_name_and_agency_id" ON "roles" ("name", "agency_id");
CREATE INDEX "index_role_permissions_on_role_id" ON "role_permissions" ("role_id");
CREATE INDEX "index_role_permissions_on_permission_id" ON "role_permissions" ("permission_id");
CREATE UNIQUE INDEX "index_role_permissions_on_role_id_and_permission_id" ON "role_permissions" ("role_id", "permission_id");
CREATE INDEX "index_user_roles_on_user_id" ON "user_roles" ("user_id");
CREATE INDEX "index_user_roles_on_role_id" ON "user_roles" ("role_id");
CREATE UNIQUE INDEX "index_user_roles_on_user_id_and_role_id" ON "user_roles" ("user_id", "role_id");
COMMIT;
