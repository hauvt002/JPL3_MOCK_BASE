CREATE TABLE [dbo].[Ban] (
    [id]        INT IDENTITY (1, 1) NOT NULL,
    [tinhtrang] BIT DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
    );

CREATE TABLE [dbo].[DO_UONG] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [ten]        NVARCHAR (100) NULL,
    [gia]        INT            NULL,
    [MA_DO_UONG] NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
    );

CREATE TABLE [dbo].[HoaDon] (
    [id]          INT      IDENTITY (1, 1) NOT NULL,
    [idBan]       INT      NULL,
    [thoigianlap] DATETIME NULL,
    [tinhtrang]   BIT      DEFAULT ((0)) NULL,
    [tongtien]    INT      DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [pk_Ban_HoaDon] FOREIGN KEY ([idBan]) REFERENCES [dbo].[Ban] ([id]) ON DELETE CASCADE
    );

CREATE TABLE [dbo].[Product] (
    [id]     INT            IDENTITY (1, 1) NOT NULL,
    [name]   NVARCHAR (100) NULL,
    [brand]  NVARCHAR (100) NULL,
    [madein] NVARCHAR (100) NULL,
    [price]  DECIMAL (18)   NULL,
    CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED ([id] ASC)
    );

CREATE TABLE [dbo].[roles] (
    [role_id] INT          IDENTITY (1, 1) NOT NULL,
    [name]    VARCHAR (45) NOT NULL,
    PRIMARY KEY CLUSTERED ([role_id] ASC)
    );

CREATE TABLE [dbo].[TaiKhoan] (
    [tendangnhap] VARCHAR (20)    NOT NULL,
    [matkhau]     NVARCHAR (1000) NULL,
    [tenhienthi]  NVARCHAR (100)  NULL,
    [loai]        INT             NULL,
    PRIMARY KEY CLUSTERED ([tendangnhap] ASC)
    );


CREATE TABLE [dbo].[ThongTinHoaDon] (
    [id]       INT IDENTITY (1, 1) NOT NULL,
    [idHoaDon] INT NULL,
    [idDoUong] INT NULL,
    [soLuong]  INT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [pk_DoUong_ThongTinHoaDon] FOREIGN KEY ([idDoUong]) REFERENCES [dbo].[DO_UONG] ([id]) ON DELETE CASCADE,
    CONSTRAINT [pk_HoaDon_ThongTinHoaDon] FOREIGN KEY ([idHoaDon]) REFERENCES [dbo].[HoaDon] ([id]) ON DELETE CASCADE
    );

CREATE TABLE [dbo].[users] (
    [user_id]   INT          IDENTITY (1, 1) NOT NULL,
    [email]     VARCHAR (45) NULL,
    [full_name] VARCHAR (45) NULL,
    [password]  VARCHAR (64) NULL,
    [enabled]   TINYINT      DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([user_id] ASC)
    );

CREATE TABLE [dbo].[users_roles] (
    [user_id] INT NOT NULL,
    [role_id] INT NOT NULL,
     CONSTRAINT [role_fk] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([role_id]),
    CONSTRAINT [user_fk] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([user_id])
    );

INSERT INTO `roles` (`name`) VALUES ('USER');
INSERT INTO `roles` (`name`) VALUES ('CREATOR');
INSERT INTO `roles` (`name`) VALUES ('EDITOR');
INSERT INTO `roles` (`name`) VALUES ('ADMIN');

INSERT INTO `users` (`email`, `password`, `enabled`) VALUES ('patrick', '$2a$10$cTUErxQqYVyU2qmQGIktpup5chLEdhD2zpzNEyYqmxrHHJbSNDOG.', '1');
INSERT INTO `users` (`email`, `password`, `enabled`) VALUES ('alex', '$2a$10$.tP2OH3dEG0zms7vek4ated5AiQ.EGkncii0OpCcGq4bckS9NOULu', '1');
INSERT INTO `users` (`email`, `password`, `enabled`) VALUES ('john', '$2a$10$E2UPv7arXmp3q0LzVzCBNeb4B4AtbTAGjkefVDnSztOwE7Gix6kea', '1');
INSERT INTO `users` (`email`, `password`, `enabled`) VALUES ('namhm', '$2a$10$GQT8bfLMaLYwlyUysnGwDu6HMB5G.tin5MKT/uduv2Nez0.DmhnOq', '1');
INSERT INTO `users` (`email`, `password`, `enabled`) VALUES ('admin', '$2a$10$IqTJTjn39IU5.7sSCDQxzu3xug6z/LPU6IF0azE/8CkHCwYEnwBX.', '1');


INSERT INTO `users_roles` (`user_id`, `role_id`) VALUES (1, 1); -- user patrick has role USER
INSERT INTO `users_roles` (`user_id`, `role_id`) VALUES (2, 2); -- user alex has role CREATOR
INSERT INTO `users_roles` (`user_id`, `role_id`) VALUES (3, 3); -- user john has role EDITOR
INSERT INTO `users_roles` (`user_id`, `role_id`) VALUES (4, 2); -- user namhm has role CREATOR
INSERT INTO `users_roles` (`user_id`, `role_id`) VALUES (4, 3); -- user namhm has role EDITOR
INSERT INTO `users_roles` (`user_id`, `role_id`) VALUES (5, 4); -- user admin has role ADMIN
