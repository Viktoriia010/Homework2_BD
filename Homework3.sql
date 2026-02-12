USE Academy;

CREATE TABLE Teachers(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(max) CHECK(Name != '') NOT NULL,
	Surname NVARCHAR(max) CHECK(Surname != '') NOT NULL,
	Salary MONEY CHECK(Salary >= 0) NOT NULL,
);

DROP TABLE Teachers;

GO

CREATE TABLE Curators(
    id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   	Name NVARCHAR(max) CHECK(Name != '') NOT NULL,
	Surname NVARCHAR(max) CHECK(Surname != '') NOT NULL,
);

GO

CREATE TABLE Faculties(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL, 
	Financing MONEY DEFAULT(0) CHECK(Financing >= 0) NOT NULL,
	Name NVARCHAR(100) UNIQUE CHECK(Name != '') NOT NULL
);

GO

CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(100) UNIQUE CHECK(Name != '') NOT NULL,
	Financing MONEY DEFAULT(0) CHECK(Financing >= 0) NOT NULL,
	FacultyId INT FOREIGN KEY REFERENCES Faculties(id) NOT NULL
);

GO

CREATE TABLE Groups(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(10) UNIQUE CHECK(Name != '') NOT NULL,
	Year INT CHECK(Year > 0 AND Year <= 5) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(id) NOT NULL
);

GO

CREATE TABLE GroupsCurators(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CuratorId INT FOREIGN KEY REFERENCES Curators(id) NOT NULL,
	GroupId INT FOREIGN KEY REFERENCES Groups(id) NOT NULL
);

GO

CREATE TABLE Subjects(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(100) UNIQUE CHECK(Name != '') NOT NULL
);

GO

CREATE TABLE Lectures(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	LectureRoom NVARCHAR(max) CHECK(LectureRoom != '') NOT NULL,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(id) NOT NULL,
	TeacherId INT FOREIGN KEY REFERENCES Teachers(id) NOT NULL
);

GO

CREATE TABLE GroupsLectures(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	GroupId INT FOREIGN KEY REFERENCES Groups(id) NOT NULL,
	LectureId INT FOREIGN KEY REFERENCES Lectures(id) NOT NULL
);

GO

DROP TABLE Faculties;

DROP TABLE Departments;

DROP TABLE Curators;

DROP TABLE Groups;

INSERT INTO Faculties (Name, Financing)
VALUES 
(N'Комп''ютерні науки', 100000),
(N'Економіка', 80000),
(N'Інженерія', 90000);

INSERT INTO Departments (Name, Financing, FacultyId)
VALUES
(N'Програмна інженерія', 60000, 1),
(N'Системний аналіз', 50000, 1),
(N'Фінанси і кредит', 40000, 2),
(N'Механіка', 30000, 3);

INSERT INTO Groups (Name, Year, DepartmentId)
VALUES
(N'P107', 1, 1),
(N'P201', 2, 1),
(N'SA305', 3, 2),
(N'F401', 4, 3),
(N'M501', 5, 4);

INSERT INTO Curators (Name, Surname)
VALUES
(N'Іван', N'Петренко'),
(N'Марія', N'Іваненко'),
(N'Олег', N'Сидоренко');

INSERT INTO GroupsCurators (CuratorId, GroupId)
VALUES
(1, 1),
(2, 2),
(3, 5);

INSERT INTO Teachers (Name, Surname, Salary)
VALUES
(N'Samantha', N'Adams', 5000),
(N'John', N'Smith', 4500),
(N'Emily', N'Brown', 4700),
(N'Michael', N'Johnson', 5200);

INSERT INTO Subjects (Name)
VALUES
(N'Теорія баз даних'),
(N'Програмування'),
(N'Економічна теорія'),
(N'Вища математика');

INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId)
VALUES
(N'B103', 1, 1), -- Теорія БД - Samantha Adams
(N'A201', 2, 2), -- Програмування - John Smith
(N'B103', 4, 3), -- Вища математика - Emily Brown
(N'C301', 3, 4); -- Економічна теорія - Michael Johnson

INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES
(1, 1), -- P107 - Теорія БД
(1, 2), -- P107 - Програмування
(2, 2), -- P201 - Програмування
(3, 3), -- SA305 - Вища математика
(4, 4), -- F401 - Економічна теорія
(5, 3); -- M501 - Вища математика


--Вивести прізвища кураторів груп та назви груп, які вони курують.

SELECT c.name+' '+c.surname, g.name FROM Curators c
INNER JOIN GroupsCurators gc
ON gc.CuratorId = c.id  
INNER JOIN Groups g
ON gc.GroupId = g.id
GROUP BY c.name, c.surname,  g.name

--Вивести прізвища викладачів, які читають лекції у групі «P107».

SELECT  g.name, t.name+' '+t.surname FROM Teachers t
INNER JOIN Lectures l
ON l.TeacherId = t.id
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id  
INNER JOIN Groups g
ON gl.GroupId = g.id
WHERE g.name = 'P107'
GROUP BY g.name, t.name+' '+t.surname

--Вивести прізвища викладачів та назви факультетів, на яких вони читають лекції.

SELECT  t.name+' '+t.surname, f.name  FROM Teachers t
INNER JOIN Lectures l 
ON l.TeacherId = t.Id
INNER JOIN GroupsLectures gl 
ON gl.LectureId = l.Id
INNER JOIN Groups g 
ON g.Id = gl.GroupId
INNER JOIN Departments d 
ON d.Id = g.DepartmentId
INNER JOIN Faculties f 
ON f.Id = d.FacultyId
GROUP BY t.name+' '+t.surname, f.name

--Виведіть назви кафедр та назви груп, які до них відносяться.
SELECT  d.name, g.name  FROM Groups g
INNER JOIN Departments d 
ON d.Id = g.DepartmentId
GROUP BY d.name, g.name

--Виведіть назви предметів, які викладає викладач «Samantha Adams».

SELECT  s.name, t.name+' ' +t.surname  FROM Teachers t
INNER JOIN Lectures l
ON l.TeacherId = t.id
INNER JOIN Subjects s
ON l.SubjectId = s.id
WHERE t.name = 'Samantha' AND t.surname = 'Adams' 
GROUP BY s.name, t.name+' ' +t.surname

--Виведіть назви кафедр, на яких викладається предмет «Теорія баз даних».

SELECT  d.name, s.Name FROM Departments d
INNER JOIN Groups g
ON g.DepartmentId = d.id
INNER JOIN GroupsLectures gl
ON gl.GroupId = g.Id
INNER JOIN Lectures l
ON gl.LectureId = l.id
INNER JOIN Subjects s
ON l.SubjectId = s.id
WHERE s.name = 'Теорія баз даних'
GROUP BY d.name, s.Name

--Виведіть назви груп, які належать до факультету «Комп'ютерні науки».

SELECT  g.name, f.Name FROM Groups g
INNER JOIN  Departments d
ON g.DepartmentId = d.id
INNER JOIN Faculties f
ON d.FacultyId = f.id
WHERE f.name = 'Комп''ютерні науки'
GROUP BY  g.name, f.Name

--Виведіть назви груп 5-го курсу, а також назви факультетів, до яких вони від­но­сяться.

SELECT  g.name, f.Name FROM Groups g
INNER JOIN  Departments d
ON g.DepartmentId = d.id
INNER JOIN Faculties f
ON d.FacultyId = f.id
WHERE g.Year = 5
GROUP BY  g.name, f.Name

--Вивести прізвища викладачів та лекції, які вони читають (назви дисциплін та груп), причому вивести лише ті лекції, які читаються в аудиторії «B103».

SELECT t.name+' ' +t.surname, s.name, g.name FROM Teachers t
INNER JOIN Lectures l
ON l.TeacherId = t.id
INNER JOIN Subjects s
ON l.SubjectId = s.id
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id
INNER JOIN Groups g 
ON gl.GroupId = g.id
WHERE l.LectureRoom = 'B103'
GROUP BY t.name+' ' +t.surname, s.name, g.name