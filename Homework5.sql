USE Academy;


CREATE TABLE Students(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(max) CHECK(Name != '') NOT NULL,
	Rating INT CHECK(Rating >= 0 AND Rating <= 5) NOT NULL,
	Surname NVARCHAR(max) CHECK(Surname != '') NOT NULL,
)

CREATE TABLE GroupsStudents(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	GroupId INT FOREIGN KEY REFERENCES Groups(id) NOT NULL,
	StudentId INT FOREIGN KEY REFERENCES Students(id) NOT NULL
)

DROP TABLE GroupsStudents

ALTER TABLE Departments
ADD Building INT NOT NULL CHECK(Building > 0 AND Building <= 5) DEFAULT(1)

ALTER TABLE Teachers
ADD IsProfessor BIT NOT NULL DEFAULT(0)

SELECT * FROM Teachers 
SELECT * FROM Lectures 
SELECT * FROM GroupsLectures 
SELECT * FROM Groups 
SELECT * FROM Departments 
SELECT * FROM Faculties 
SELECT * FROM Curators
SELECT * FROM GroupsCurators
SELECT * FROM Subjects 
SELECT * FROM Students
SELECT * FROM GroupsStudents 

TRUNCATE TABLE GroupsCurators
TRUNCATE TABLE GroupsStudents
TRUNCATE TABLE GroupsLectures

TRUNCATE TABLE Students

DELETE FROM Lectures
DELETE FROM Teachers
DELETE FROM Groups
DELETE FROM Curators
DELETE FROM Subjects
DELETE FROM Departments
DELETE FROM Faculties
DELETE FROM Students
DELETE FROM GroupsStudents




DBCC CHECKIDENT ('Lectures', RESEED, 0);
DBCC CHECKIDENT ('Teachers', RESEED, 0);
DBCC CHECKIDENT ('Groups', RESEED, 0);
DBCC CHECKIDENT ('Curators', RESEED, 0);
DBCC CHECKIDENT ('Subjects', RESEED, 0);
DBCC CHECKIDENT ('Departments', RESEED, 0);
DBCC CHECKIDENT ('Faculties', RESEED, 0);
DBCC CHECKIDENT ('Students', RESEED, 0);
DBCC CHECKIDENT ('GroupsStudents', RESEED, 0);



INSERT INTO Faculties (Name, Financing)
VALUES
('Computer Science', 50000),
('Engineering', 30000),
('Economics', 20000);

--Очистити поле Id в інсертах

SELECT * FROM Faculties;

INSERT INTO Departments (Name, Financing, FacultyId, Building)
VALUES
('Software Development', 80000, 1, 1),
('Artificial Intelligence', 40000, 1, 1),
('Mechanical Engineering', 60000, 2, 2),
('Finance', 50000, 3, 3);

INSERT INTO Groups (Name, Year, DepartmentId)
VALUES
('SD401', 4, 1),
('SD501', 5, 1),
('D221', 5, 1),
('ME501', 5, 3),
('FI301', 3, 4);

INSERT INTO Subjects (Name)
VALUES
('Databases'),
('Algorithms'),
('Machine Learning'),
('Mechanics'),
('Accounting');

INSERT INTO Teachers (Name, Surname, Salary, IsProfessor)
VALUES
('Ivan', 'Petrenko', 5000, 0),
('Olena', 'Koval', 7000, 1),
('Andriy', 'Melnyk', 9000, 1),
('Maria', 'Shevchenko', 4000, 0),
('Oleg', 'Bondar', 9500, 1);

INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId, DayOfWeek)
VALUES
('A101',1,2,1),
('A102',1,2,2),
('A103',1,2,3),
('A104',2,3,1),
('A105',2,3,2),
('A106',2,3,3),
('A107',3,5,1),
('A108',3,5,2),
('A109',3,5,3),
('A110',1,5,4),
('A111',2,5,5),
('B201',4,4,1),
('C301',5,1,1);

INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES
-- SD501 більше 10
(2,1),(2,2),(2,3),(2,4),(2,5),
(2,6),(2,7),(2,8),(2,9),(2,10),(2,11),

-- D221 менше
(3,1),(3,4),(3,7),

-- Інші групи
(4,12),
(5,13)

INSERT INTO Students (Name, Rating, Surname)
VALUES
('Anna', 2, 'Ivanova'),
('Petro',4,'Koval'),
('Ira',3,'Bondar'),
('Max',1,'Shevchenko'),
('Oksana',5,'Melnyk'),
('Taras',4,'Petrenko')

SELECT * FROM GroupsStudents;

INSERT INTO GroupsStudents (GroupId, StudentId)
VALUES
-- SD501 (високий рейтинг)
(2,1),
(2,2),
(2,5)

SELECT * FROM Students;

INSERT INTO GroupsStudents (GroupId, StudentId)
VALUES
-- D221 (середній рейтинг ~70)
(3,3),
(3,4)

INSERT INTO GroupsStudents (GroupId, StudentId)
VALUES
-- ME501 (низький рейтинг)
(4,6)

INSERT INTO Curators (Name, Surname)
VALUES
('Stepan','Tkachenko'),
('Nadia','Lysenko'),
('Roman','Danyliuk');

INSERT INTO GroupsCurators (CuratorId, GroupId)
VALUES
-- SD501 має 2 кураторів
(1,2),
(2,2),

-- інші
(3,3);


--Вивести номери корпусів, якщо сумарний фонд фінансування розташованих у них кафедр перевищує 100000.

SELECT d.Building
FROM Departments d
WHERE (
	SELECT SUM(Financing)
	FROM Departments
	WHERE Building = d.Building
) > 100000
GROUP BY Building;

--Вивести назви груп 5-го курсу кафедри «Software Development», які мають понад 10 пар на перший тиждень.

SELECT g.Name FROM Groups g
WHERE g.Year = 5 AND g.DepartmentId IN (
	SELECT d.id
	FROM Departments d
	WHERE d.Name = N'Software Development'
)
AND (
    SELECT COUNT(*)
    FROM GroupsLectures gl
    INNER JOIN Lectures l 
	ON l.id = gl.LectureId
    WHERE gl.GroupId = g.id AND l.DayOfWeek >= 1 AND l.DayOfWeek <= 7
) > 10;

--Вивести назви груп, які мають рейтинг (середній рейтинг усіх студентів групи) більший, ніж рейтинг групи «D221».

SELECT g.Name 
FROM Groups g
WHERE (
	SELECT AVG(s.Rating) 
	FROM Students s
	INNER JOIN GroupsStudents gs
		ON gs.StudentId = s.id
	WHERE gs.GroupId = g.id 
) > 
(
	SELECT AVG(s.Rating)
	FROM Students s
	INNER JOIN GroupsStudents gs
		ON gs.StudentId = s.id
	INNER JOIN Groups g2
		ON g2.id = gs.GroupId
	WHERE g2.Name = N'D221'
);

--Вивести прізвища та імена викладачів, ставка яких вища за середню ставку про­фесорів.

SELECT t.Name+' '+ t.Surname FROM Teachers t 
WHERE t.Salary > 
(
	SELECT AVG(t2.Salary) FROM Teachers t2
	WHERE t2.IsProfessor = 1
)

--Вивести назви груп, які мають більше одного куратора.

SELECT g.Name FROM Groups g
WHERE (
	SELECT COUNT(c.id) FROM Curators c
	INNER JOIN GroupsCurators gc
	ON gc.CuratorId = c.id
	WHERE gc.GroupId = g.id
) > 1

--Вивести назви груп, які мають рейтинг (середній рейтинг усіх студентів групи) менший, ніж мінімальний рейтинг груп 5-го курсу.

SELECT g.Name FROM Groups g
WHERE (
	SELECT AVG(s.Rating) FROM Students s
	INNER JOIN GroupsStudents gs
	ON gs.StudentId = s.id
	WHERE gs.GroupId = g.Id
) < (
	SELECT MIN(AvgRating)
	FROM(
		SELECT AVG(s.Rating) AS AvgRating
		FROM Students s
		INNER JOIN GroupsStudents gs
		ON gs.StudentId = s.id
		INNER JOIN Groups g1
		ON gs.GroupId = g1.Id
		WHERE g1.Year = 5
		GROUP BY g1.id
	) AS R
)

--Вивести назви дисциплін та повні імена викладачів, які читають найбільшу кіль­кість лекцій з них.

SELECT s.Name, t.Name + ' ' + t.Surname
FROM Subjects s
JOIN Lectures l ON l.SubjectId = s.Id
JOIN Teachers t ON t.Id = l.TeacherId
GROUP BY s.Id, s.Name, t.Id, t.Name, t.Surname
HAVING COUNT(l.Id) = (
    SELECT MAX(LecCount)
    FROM (
        SELECT COUNT(l2.Id) AS LecCount
        FROM Lectures l2
        WHERE l2.SubjectId = s.Id
        GROUP BY l2.TeacherId
    ) AS T
)

--Вивести назву дисципліни, за якою читається найменше лекцій.

SELECT s.Name
FROM Subjects s
JOIN Lectures l ON l.SubjectId = s.Id
GROUP BY s.Id, s.Name
HAVING COUNT(*) = (
    SELECT MIN(LecCount)
    FROM (
        SELECT COUNT(*) AS LecCount
        FROM Lectures
        GROUP BY SubjectId
    ) AS Counts
);

