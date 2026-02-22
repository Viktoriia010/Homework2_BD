

USE Academy

CREATE DATABASE Academy

GO

CREATE TABLE LectureRooms(
	Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Building INT NOT NULL CHECK(Building >=1 AND Building<=5),
	Name NVARCHAR(10) UNIQUE CHECK(Name != '') NOT NULL
);

GO

CREATE TABLE Subjects(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(100) UNIQUE CHECK(Name != '') NOT NULL
);

GO

CREATE TABLE Teachers(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(max) CHECK(Name != '') NOT NULL,
	Surname NVARCHAR(max) CHECK(Surname != '') NOT NULL
);

GO

CREATE TABLE Assistants(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE Curators(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE Deans(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE Faculties(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Building INT  NOT NULL CHECK(Building >=1 AND Building<=5),
	Name NVARCHAR(100) UNIQUE CHECK(Name != '') NOT NULL,
	DeanId INT NOT NULL FOREIGN KEY REFERENCES Deans(id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE Heads(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Building INT  NOT NULL CHECK(Building >=1 AND Building<=5),
	Name NVARCHAR(100) UNIQUE CHECK(Name != '') NOT NULL,
	FacultyId INT NOT NULL FOREIGN KEY REFERENCES Faculties(id)
	ON DELETE CASCADE ON UPDATE CASCADE,
	HeadId INT NOT NULL FOREIGN KEY REFERENCES Heads(id)
);

GO

CREATE TABLE Groups(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Building INT  NOT NULL CHECK(Building >=1 AND Building<=5),
	Name NVARCHAR(10) UNIQUE CHECK(Name != '') NOT NULL,
	Year INT CHECK(Year > 0 AND Year <= 5) NOT NULL,
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(id) 
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE GroupsCurators(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CuratorId INT NOT NULL FOREIGN KEY REFERENCES Curators(id) 
	ON DELETE CASCADE ON UPDATE CASCADE,
	GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(id)
);

GO

CREATE TABLE Lectures(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(id) 
	ON DELETE CASCADE ON UPDATE CASCADE,
	TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE GroupsLectures(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(id),
	LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(id) 
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE Schedules(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Class INT CHECK(Class > 0 AND Class <=8) NOT NULL,
	DayOfWeek INT CHECK(DayOfWeek > 0 AND DayOfWeek <=7) NOT NULL,
	Week INT CHECK(Week > 0 AND Week <=52) NOT NULL,
	LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(id) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    LectureRoomId INT NOT NULL FOREIGN KEY REFERENCES LectureRooms(id) 
	ON DELETE CASCADE ON UPDATE CASCADE
);

GO

INSERT INTO Subjects (Name) VALUES
('Databases'),
('Algorithms'),
('Computer Networks'),
('Software Engineering');

INSERT INTO Teachers (Name, Surname) VALUES
('Edward', 'Hopper'),
('Alex', 'Carmack'),
('John', 'Smith'),
('Emma', 'Stone'),
('Michael', 'Brown'),
('Sarah', 'Connor'),
('David', 'Wilson');

INSERT INTO Assistants (TeacherId) VALUES
(3),
(4);

INSERT INTO Curators (TeacherId) VALUES
(5),
(6);

INSERT INTO Deans (TeacherId) VALUES
(7);

INSERT INTO Heads (TeacherId) VALUES
(2);

INSERT INTO Faculties (Building, Name, DeanId) VALUES
(5, 'Computer Science', 1);

INSERT INTO Departments (Building, Name, FacultyId, HeadId) VALUES
(5, 'Software Development', 1, 1);

INSERT INTO Groups (Building, Name, Year, DepartmentId) VALUES
(5, 'F505', 5, 1),
(5, 'F404', 4, 1);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
(1, 1),
(2, 2);

INSERT INTO Subjects (Name) VALUES
('Databases'),
('Algorithms'),
('Computer Networks'),
('Software Engineering');

INSERT INTO Lectures (SubjectId, TeacherId) VALUES
(1, 1), -- Edward Hopper
(2, 2), -- Alex Carmack
(4, 2); -- Alex Carmack

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 2);

INSERT INTO LectureRooms (Building, Name) VALUES
(5, 'A311'),
(5, 'A104'),
(5, 'B201');

INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES
-- Edward Hopper (понеділок)
(1, 1, 1, 1, 1),

-- Alex Carmack (середа, 2 тиждень, 3 пара)
(3, 3, 2, 2, 1),

-- Alex Carmack (п'ятниця)
(2, 5, 1, 3, 2);

SELECT* FROM Schedules

SELECT * FROM LectureRooms;

INSERT INTO Lectures (SubjectId, TeacherId)
VALUES (3, 3);

INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES (1, 4);

--Вивести назви аудиторій, де читає лекції викладач «Edward Hopper».

SELECT lr.Name FROM LectureRooms lr
INNER JOIN Schedules sch
ON sch.LectureRoomId = lr.Id
INNER JOIN Lectures l
ON sch.LectureId = l.id
INNER JOIN Teachers t
ON t.id = l.TeacherId
WHERE t.name + ' ' + t.Surname = 'Edward Hopper';

--Вивести прізвища асистентів, які читають лекції у групі «F505».

SELECT t.Name + ' ' + t.Surname FROM Assistants a
INNER JOIN Teachers t
ON a.TeacherId = t.id
INNER JOIN Lectures l
ON t.id = l.TeacherId
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id
INNER JOIN Groups g
ON gl.GroupId = g.id
WHERE g.Name = 'F505'

--Вивести дисципліни, які читає викладач «Alex Carmack» для груп 5 курсу.

SELECT s.Name FROM Subjects s
INNER JOIN Lectures l
ON l.SubjectId = s.id
INNER JOIN Teachers t
ON t.id = l.TeacherId
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id
INNER JOIN Groups g
ON gl.GroupId = g.id
WHERE t.name + ' ' + t.Surname = 'Alex Carmack' AND g.Year = 5

--Вивести прізвища викладачів, які не читають лекції у понеділок.

SELECT t.Name + ' ' + t.Surname, l.id, s.DayOfWeek FROM Teachers t
LEFT JOIN Lectures l
ON l.TeacherId = t.id
LEFT JOIN Schedules s
ON s.LectureId = l.id
WHERE l.id IS NULL OR s.DayOfWeek != 1

--Вивести назви аудиторій, із зазначенням їх корпусів, у яких немає лекцій у середу другого тижня на третій парі.

SELECT lr.Name, lr.Building, l.id, s.Class, s.DayOfWeek, s.Week FROM LectureRooms lr
LEFT JOIN Schedules s
ON s.LectureRoomId = lr.id
LEFT JOIN Lectures l
ON s.LectureId = l.id
WHERE s.DayOfWeek != 3 AND s.Class != 3 AND s.Week != 2	OR l.id IS NULL

--Вивести повні імена викладачів факультету «Computer Science», які не курирують групи кафедри «Software Development».

SELECT t.Name + ' ' + t.Surname, f.Name, g.name, dep.Name FROM Teachers t
LEFT JOIN Deans d
ON d.TeacherId = t.id
LEFT JOIN Faculties f
ON f.DeanId = d.id
LEFT JOIN Curators c
ON c.TeacherId = t.id
LEFT JOIN GroupsCurators gc
ON gc.CuratorId = c.id
LEFT JOIN Groups g
ON gc.GroupId = g.id
LEFT JOIN Departments dep
ON g.DepartmentId = dep.id
    AND dep.Name = 'Software Development'
WHERE f.Name = 'Computer Science'
AND dep.id IS NULL;

--Вивести список номерів усіх корпусів, які є у таблицях факультетів, кафедр та аудиторій.

SELECT Building FROM Departments 
UNION
SELECT Building FROM Faculties
UNION
SELECT Building FROM LectureRooms 

--Вивести повні імена викладачів у такому порядку: декани факультетів, завідувачі кафедр, викладачі, куратори, асистенти.

SELECT t.name+' ' + t.surname FROM Deans
INNER JOIN Teachers t
ON t.id = Deans.TeacherId
UNION ALL
SELECT t.name+' ' + t.surname FROM Heads
INNER JOIN Teachers t
ON t.id = Heads.TeacherId
UNION ALL
SELECT t.name+' ' + t.surname FROM Teachers t
UNION ALL
SELECT t.name+' ' + t.surname FROM Curators
INNER JOIN Teachers t
ON t.id = Curators.TeacherId
UNION ALL
SELECT t.name+' ' + t.surname FROM Assistants
INNER JOIN Teachers t
ON t.id = Assistants.TeacherId

