USE Academy


INSERT INTO Faculties (Name)
VALUES (N'Computer Science');

INSERT INTO Departments (Name, Financing, FacultyId)
VALUES (N'Software Development', 75000,
        (SELECT Id FROM Faculties WHERE Name = N'Computer Science'));

INSERT INTO Teachers (Name, Surname, Salary)
VALUES
(N'Dave', N'McQueen', 6000),
(N'Jack', N'Underhill', 6500);

ALTER TABLE Lectures
ADD DayOfWeek INT NOT NULL DEFAULT 1;

INSERT INTO Lectures (DayOfWeek, LectureRoom, SubjectId, TeacherId)
VALUES
(1, N'D201', 1, (SELECT Id FROM Teachers WHERE Surname = N'McQueen')),
(2, N'D201', 2, (SELECT Id FROM Teachers WHERE Surname = N'Underhill'));

SELECT * FROM Teachers 
SELECT * FROM Lectures 
SELECT * FROM GroupsLectures 
SELECT * FROM Groups 
SELECT * FROM Departments 
SELECT * FROM Faculties 



INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES
(7, 5)

INSERT INTO Groups (Name, Year, DepartmentId)
VALUES
('P202',5, 5)


--Вивести кількість викладачів кафедри «Software Development».

SELECT COUNT(t.Name+' '+t.Surname) 
FROM Teachers AS t
INNER JOIN Lectures l 
ON l.TeacherId = t.id
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id
INNER JOIN Groups g
ON gl.GroupId = g.id
INNER JOIN Departments d
ON g.DepartmentId = d.id
WHERE d.Name = N'Software Development'

--Вивести кількість лекцій, які читає викладач «Dave McQueen».

SELECT COUNT(l.id) 
FROM Lectures l
INNER JOIN Teachers t
ON l.TeacherId = t.id
WHERE t.Name+' '+t.Surname = N'Dave McQueen'

--Вивести кількість занять, які проводяться в аудиторії «D201».

SELECT COUNT(s.name) 
FROM Subjects s
INNER JOIN Lectures l 
ON l.SubjectId = s.id
WHERE l.LectureRoom = N'D201'

--Вивести назви аудиторій та кількість лекцій, що проводяться в них.

SELECT l.LectureRoom, COUNT(l.id)
FROM Lectures l 
GROUP BY l.LectureRoom

--Вивести середню ставку викладачів факультету «Computer Science».

SELECT AVG(t.Salary) 
FROM Teachers AS t
INNER JOIN Lectures l 
ON l.TeacherId = t.id
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id
INNER JOIN Groups g
ON gl.GroupId = g.id
INNER JOIN Departments d
ON g.DepartmentId = d.id
INNER JOIN Faculties f
ON d.FacultyId = f.id
WHERE f.Name = N'Computer Science'

--Вивести середній фонд фінансування кафедр.

SELECT AVG(d.Financing) 
FROM Departments d

--Вивести повні імена викладачів та кількість читаних ними дисциплін.

SELECT t.Name+' '+t.Surname, COUNT(s.Name) 
FROM Teachers AS t
INNER JOIN Lectures l 
ON l.TeacherId = t.id
INNER JOIN Subjects s
ON s.id = l.SubjectId
GROUP BY t.Name+' '+t.Surname

--Вивести номери аудиторій та кількість кафедр, чиї лекції в них читаються.

SELECT l.LectureRoom ,COUNT(d.Name) 
FROM  Lectures l 
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id
INNER JOIN Groups g
ON gl.GroupId = g.id
INNER JOIN Departments d
ON g.DepartmentId = d.id
GROUP BY l.LectureRoom

--Вивести назви факультетів та кількість дисциплін, які на них читаються.

SELECT f.Name, COUNT(s.name) 
FROM Subjects s
INNER JOIN Lectures l 
ON l.SubjectId = s.id
INNER JOIN GroupsLectures gl
ON gl.LectureId = l.id
INNER JOIN Groups g
ON gl.GroupId = g.id
INNER JOIN Departments d
ON g.DepartmentId = d.id
INNER JOIN Faculties f
ON d.FacultyId = f.id
GROUP BY f.Name

--Вивести кількість лекцій для кожної пари викладач-аудиторія.

SELECT t.Name+' '+t.Surname, l.LectureRoom, COUNT(l.id) 
FROM Teachers AS t
INNER JOIN Lectures l 
ON l.TeacherId = t.id
GROUP BY t.Name+' '+t.Surname, l.LectureRoom