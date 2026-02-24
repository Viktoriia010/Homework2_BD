CREATE DATABASE sports_shop

USE sports_shop

CREATE TABLE customers(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(100) CHECK(Name != '') NOT NULL,
	Surname NVARCHAR(100) CHECK(Surname != '') NOT NULL,
	contact_phone NVARCHAR(50) NOT NULL,
	gender NVARCHAR(30) CHECK(gender != '') NOT NULL,
	discount_percent DECIMAL(10,2) DEFAULT(0.00) NOT NULL,
	subscribed BIT NOT NULL
);

CREATE TABLE employees(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(100) CHECK(Name != '') NOT NULL,
	Surname NVARCHAR(100) CHECK(Surname != '') NOT NULL,
	position NVARCHAR(100) CHECK(position != '') NOT NULL,
	EmploymentDate DATE NOT NULL,
	gender NVARCHAR(30) CHECK(gender != '') NOT NULL,
	salary DECIMAL(10,2) DEFAULT(0) NOT NULL
)

CREATE TABLE goods(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(100) CHECK(Name != '') NOT NULL,
	Type NVARCHAR(50) CHECK(Type != '') NOT NULL,
	quantity INT DEFAULT(0) NOT NULL,
	costPrice DECIMAL(10,2) NOT NULL,
	manufacturer NVARCHAR(100) CHECK(manufacturer != '') NOT NULL,
	sellingPrice DECIMAL(10,2) NOT NULL
)


CREATE TABLE sales(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	goodsId INT NULL FOREIGN KEY REFERENCES goods(id) 
	ON DELETE SET NULL ON UPDATE CASCADE,
	Price DECIMAL(10,2) NOT NULL,
	quantity INT DEFAULT(0) NOT NULL,
	saleDate DATE NOT NULL,
	employeeId INT NULL FOREIGN KEY REFERENCES employees(id)
	ON DELETE SET NULL ON UPDATE CASCADE,
	customerId INT NULL FOREIGN KEY REFERENCES customers(id)
	ON DELETE SET NULL ON UPDATE CASCADE
)

CREATE TABLE ArchiveOfEmployees(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	EmployeeId INT NOT NULL,
	Name NVARCHAR(100) NOT NULL,
	Surname NVARCHAR(100) NOT NULL,
	position NVARCHAR(100) NOT NULL,
	EmploymentDate DATE NOT NULL,
	gender NVARCHAR(30) NOT NULL,
	salary DECIMAL(10,2) NOT NULL,
	DismissalDate DATE DEFAULT GETDATE()     
)

DROP TABLE ArchiveOfEmployees

CREATE TRIGGER employeeDeleteTrigger
ON employees
AFTER DELETE
AS
BEGIN
	INSERT INTO ArchiveOfEmployees (EmployeeId, Name, Surname, position, EmploymentDate, gender, salary)
	SELECT id, Name, Surname, position, EmploymentDate, gender, salary
	FROM deleted;

	PRINT('Співробітника перенесено в таблицю архіву');
END

INSERT INTO employees (Name, Surname, position, EmploymentDate, gender, salary)
VALUES ('Іван', 'Іваненко', 'Продавець', '2022-05-01', 'Чоловік', 12000.00);

SELECT * FROM employees;

DELETE FROM employees
WHERE Id = 1;

SELECT * FROM ArchiveOfEmployees;
