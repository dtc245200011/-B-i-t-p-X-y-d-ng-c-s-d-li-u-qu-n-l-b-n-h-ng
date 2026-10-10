-- Tạo cơ sở dữ liệu và chọn
DROP DATABASE IF EXISTS QuanLyBanHang;
CREATE DATABASE QuanLyBanHang;
USE QuanLyBanHang;

-- Bảng Customer
CREATE TABLE Customer (
  cID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  cName VARCHAR(100) NOT NULL,
  cAge TINYINT,
  cAddress VARCHAR(255),
  cPhone VARCHAR(20)
);

-- Bảng Product
CREATE TABLE Product (
  pID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pName VARCHAR(150) NOT NULL,
  pPrice DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  pStock INT NOT NULL DEFAULT 0
);

-- Bảng Orders (một khách có nhiều hóa đơn)
CREATE TABLE Orders (
  oID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  cID INT NOT NULL,
  oDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  oTotalPrice DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  FOREIGN KEY (cID) REFERENCES Customer(cID)
);

-- Bảng OrderDetail (chi tiết hóa đơn, khóa chính kép)
CREATE TABLE OrderDetail (
  oID INT NOT NULL,
  pID INT NOT NULL,
  odQTY INT NOT NULL CHECK (odQTY > 0),
  odPrice DECIMAL(12,2) NOT NULL, -- giá tại thời điểm bán
  PRIMARY KEY (oID, pID),
  FOREIGN KEY (oID) REFERENCES Orders(oID) ON DELETE CASCADE,
  FOREIGN KEY (pID) REFERENCES Product(pID)
);
-- Thêm dữ liệu mẫu
INSERT INTO Customer (cName, cAge, cAddress, cPhone) VALUES
('Nguyen Van A', 30, 'Hanoi', '0123456789'),
('Tran Thi B', 25, 'HCMC', '0987654321');

INSERT INTO Product (pName, pPrice, pStock) VALUES
('Banh mi', 10000.00, 200),
('Sua tươi', 25000.00, 100),
('Nuoc ngot', 15000.00, 50);

-- Tạo hóa đơn cho khách 1
INSERT INTO Orders (cID, oDate, oTotalPrice) VALUES (1, '2026-10-10 10:00:00', 0.00);
SET @last_oID = LAST_INSERT_ID();

-- Thêm chi tiết hóa đơn
INSERT INTO OrderDetail (oID, pID, odQTY, odPrice) VALUES
(@last_oID, 1, 2, 10000.00),
(@last_oID, 2, 1, 25000.00);

-- Cập nhật tổng tiền hóa đơn
UPDATE Orders o
SET o.oTotalPrice = (
  SELECT IFNULL(SUM(od.odQTY * od.odPrice),0) FROM OrderDetail od WHERE od.oID = o.oID
)
WHERE o.oID = @last_oID;

-- Kịch bản thêm hóa đơn khác cho cùng khách
INSERT INTO Orders (cID, oDate) VALUES (1, '2026-10-11 15:30:00');
INSERT INTO OrderDetail (oID, pID, odQTY, odPrice) VALUES (LAST_INSERT_ID(), 3, 3, 15000.00);
-- Lấy hóa đơn cùng chi tiết cho một khách
SELECT o.oID, o.oDate, o.oTotalPrice, c.cName, od.pID, p.pName, od.odQTY, od.odPrice
FROM Orders o
JOIN Customer c ON o.cID = c.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
WHERE c.cID = 1
ORDER BY o.oDate;

-- Tổng doanh thu theo ngày
SELECT DATE(oDate) AS Ngay, SUM(oTotalPrice) AS DoanhThu
FROM Orders
GROUP BY DATE(oDate);
