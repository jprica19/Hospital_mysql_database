-- Create PERSONS table
CREATE TABLE PERSONS
(
    SSN       INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50)
);

-- INSERT INTO PERSONS table
INSERT INTO PERSONS (SSN, FirstName, LastName) VALUES
(123456789, 'John', 'Doe'),
(987654321, 'Jane', 'Smith');

-- Create PHYSICIANS table
CREATE TABLE PHYSICIANS
(
    EmployeeID   INT PRIMARY KEY
    PersonID INT NOT NULL,
    CONSTRAINT fk_physician_person FOREIGN KEY (PersonSSN) REFERENCES PERSONS (SSN)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PersonSSN    int not null,
    DepartmentID int not null,
    PersonID int not null
);

-- INSERT INTO PHYSICIANS table
INSERT INTO PHYSICIANS (EmployeeID, PersonID, PersonSSN, DepartmentID) VALUES
(1, 1, 123456789, 1),
(2, 2, 987654321, 2);


-- Create NURSES table
CREATE TABLE NURSES (
    EmployeeID INT PRIMARY KEY,
    Person INT,
    PersonSSN int not null,
    FOREIGN KEY (Person) REFERENCES PERSONS(SSN) ON UPDATE CASCADE ON DELETE CASCADE
);

-- INSERT INTO NURSES table
INSERT INTO NURSES (EmployeeID, Person, PersonSSN) VALUES
(101, 3, 111222333),
(102, 4, 444555666);

-- Create DEPARTMENTS table
CREATE TABLE DEPARTMENTS
(
    DepartmentID INT PRIMARY KEY,
    Head         INT,
    FOREIGN KEY (Head) REFERENCES PHYSICIANS (EmployeeID) ON UPDATE CASCADE ON DELETE SET NULL,
    Position     int not null
);

-- INSERT INTO DEPARTMENTS table
INSERT INTO DEPARTMENTS (DepartmentID, Head, Position) VALUES
(1, 1, 1),
(2, 2, 2);


-- Create BLOCKS table
CREATE TABLE BLOCKS (
    BlockFloor INT,
    BlockCode VARCHAR(10),
    PRIMARY KEY (BlockFloor, BlockCode)
);

-- INSERT INTO BLOCKS table
INSERT INTO BLOCKS (BlockFloor, BlockCode) VALUES
(1, 'A'),
(2, 'B');

-- Create ROOMS table
CREATE TABLE ROOMS (
    RoomNumber INT PRIMARY KEY,
    BlockFloor INT,
    BlockCode VARCHAR(10),
    FOREIGN KEY (BlockFloor, BlockCode) REFERENCES BLOCKS(BlockFloor, BlockCode) ON UPDATE CASCADE ON DELETE CASCADE
);

-- INSERT INTO ROOMS table
INSERT INTO ROOMS (RoomNumber, BlockFloor, BlockCode) VALUES
(101, 1, 'A'),
(102, 1, 'A'),
(103, 2, 'B');


-- Create PATIENTS table
CREATE TABLE PATIENTS
(
    PatientID INT PRIMARY KEY,
    Person    INT,
    PersonSSN int not null,
    FOREIGN KEY (Person) REFERENCES PERSONS (SSN) ON UPDATE CASCADE ON DELETE CASCADE
);

-- INSERT INTO PATIENTS table
INSERT INTO PATIENTS (PatientID, Person, PersonSSN) VALUES
(1, 5, 777888999),
(2, 6, 111222333);

-- Create MEDICATIONS table
CREATE TABLE MEDICATIONS (
    Code VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50)
);

-- INSERT INTO MEDICATIONS table
INSERT INTO MEDICATIONS (Code, FirstName) VALUES
('MED001', 'Medication1'),
('MED002', 'Medication2');


-- Create APPOINTMENTS table
CREATE TABLE APPOINTMENTS
(
    AppointmentID INT PRIMARY KEY,
    PrepNurse     INT,
    Patient       INT,
    Physician     INT,
    StartDateTime int not null,
    FOREIGN KEY (PrepNurse) REFERENCES NURSES (EmployeeID) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (Patient) REFERENCES PATIENTS (PatientID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Physician) REFERENCES PHYSICIANS (EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- INSERT INTO APPOINTMENTS table
INSERT INTO APPOINTMENTS (AppointmentID, PrepNurse, Patient, Physician, StartDateTime) VALUES
(1001, 101, 1, 1, 1631623200),
(1002, 102, 2, 2, 1631623200);


-- Create PROCEDURES table
CREATE TABLE PROCEDURES (
    Code VARCHAR(10) PRIMARY KEY
);

-- INSERT INTO PROCEDURES table
INSERT INTO PROCEDURES (Code) VALUES
('PROC001'),
('PROC002');


-- Create STAYS table
CREATE TABLE STAYS (
    StayID INT PRIMARY KEY,
    Patient INT,
    Room INT,
    FOREIGN KEY (Patient) REFERENCES PATIENTS(PatientID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Room) REFERENCES ROOMS(RoomNumber) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create AFFILIATED_WITH table
CREATE TABLE AFFILIATED_WITH (
    Physician INT,
    Department INT,
    PRIMARY KEY (Physician, Department),
    FOREIGN KEY (Department) REFERENCES DEPARTMENTS(DepartmentID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Physician) REFERENCES PHYSICIANS(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create PRESCRIBES table
CREATE TABLE PRESCRIBES (
    Appointment INT,
    Medication VARCHAR(10),
    Patient INT,
    Physician INT,
    FOREIGN KEY (Appointment) REFERENCES APPOINTMENTS(AppointmentID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Medication) REFERENCES MEDICATIONS(Code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Patient) REFERENCES PATIENTS(PatientID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Physician) REFERENCES PHYSICIANS(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create ON_CALL table
CREATE TABLE ON_CALL (
    BlockFloor INT,
    BlockCode VARCHAR(10),
    Nurse INT,
    RoomNumber int not null,
    FOREIGN KEY (BlockFloor, BlockCode) REFERENCES BLOCKS(BlockFloor, BlockCode) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Nurse) REFERENCES NURSES(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create TRAINED_IN table
CREATE TABLE TRAINED_IN (
    Physician INT,
    Treatment VARCHAR(10),
    FOREIGN KEY (Physician) REFERENCES PHYSICIANS(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Treatment) REFERENCES PROCEDURES(Code) ON UPDATE CASCADE ON DELETE CASCADE
);

-- INSERT INTO TRAINED_IN table
INSERT INTO TRAINED_IN (Physician, Treatment) VALUES
(1, 'PROC001'),
(2, 'PROC002');


-- Create UNDERGOES table
CREATE TABLE UNDERGOES (
    AssistingNurse INT,
    Patient INT,
    Physician INT,
    Procedures VARCHAR(10),
    Stay INT,
    FOREIGN KEY (AssistingNurse) REFERENCES NURSES(EmployeeID) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (Patient) REFERENCES PATIENTS(PatientID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Physician) REFERENCES PHYSICIANS(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Procedures) REFERENCES PROCEDURES(Code) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Stay) REFERENCES STAYS(StayID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Procedure
CREATE PROCEDURE SP_Mailing_List()
BEGIN
    SELECT p.SSN, pt.PatientID, CONCAT(p.SSN, '@hospital.com') AS Email
    FROM PERSONS p
    JOIN PATIENTS pt ON p.SSN = pt.PersonSSN;
END;

DELIMITER ;

-- Procedure
CREATE PROCEDURE SP_Physicians_Position()
BEGIN
    SELECT p.FirstName, p.LastName, d.Position
    FROM PHYSICIANS ph
    JOIN PERSONS p ON ph.PersonSSN = p.SSN
    JOIN DEPARTMENTS d ON ph.DepartmentID = d.DepartmentID;
END;

DELIMITER ;

-- Procedure
CREATE PROCEDURE SP_Num_Patient_Appointments()
BEGIN
    SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Patient,
           COUNT(DISTINCT a.Physician) AS `Appointment for No. of Physicians`
    FROM PATIENTS pt
    JOIN PERSONS p ON pt.PersonSSN = p.SSN
    JOIN APPOINTMENTS a ON pt.PatientID = a.Patient
    GROUP BY pt.PatientID;
END;
CALL SP_Num_Patient_Appointments();

DELIMITER ;

-- Procedure
CREATE PROCEDURE SP_Patient_Rooms()
BEGIN
    SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Patient,
           r.RoomNumber AS `Room No.`,
           a.StartDateTime AS `Date and Time of appointment`
    FROM PATIENTS pt
    JOIN PERSONS p ON pt.PersonSSN = p.SSN
    JOIN APPOINTMENTS a ON pt.PatientID = a.Patient
    JOIN STAYS s ON pt.PatientID = s.Patient
    JOIN ROOMS r ON s.Room = r.RoomNumber;
END;
CALL SP_Patient_Rooms();

DELIMITER ;

-- Procedure
CREATE PROCEDURE SP_Patient_Medications()
BEGIN
    SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Patient,
           ph.EmployeeID AS Physician,
           m.FirstNAME AS Medication
    FROM PATIENTS pt
    JOIN PERSONS p ON pt.PersonSSN = p.SSN
    JOIN APPOINTMENTS a ON pt.PatientID = a.Patient
    JOIN PHYSICIANS ph ON a.Physician = ph.EmployeeID
    JOIN PRESCRIBES pr ON a.AppointmentID = pr.Appointment
    JOIN MEDICATIONS m ON pr.Medication = m.Code;
END;
CALL SP_Patient_Medications();

DELIMITER ;

-- Procedure
CREATE PROCEDURE SP_Num_Rooms_Floor()
BEGIN
    SELECT BLOCKS.BlockFloor AS Floor,
           COUNT(ROOMS.RoomNumber) AS `No of available rooms`
    FROM BLOCKS
    LEFT JOIN ROOMS ON BLOCKS.BlockFloor = ROOMS.BlockFloor AND BLOCKS.BlockCode = ROOMS.BlockCode
    LEFT JOIN STAYS ON ROOMS.RoomNumber = STAYS.Room
    WHERE STAYS.Room IS NULL
    GROUP BY `Blocks`.BlockFloor
    ORDER BY `No of available rooms`
    LIMIT 1;
END;
CALL SP_Num_Rooms_Floor();

DELIMITER ;

CREATE PROCEDURE SP_Nurses_122()
BEGIN
    SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Nurse_Name
    FROM NURSES n
    JOIN PERSONS p ON n.PersonSSN = p.SSN
    JOIN ON_CALL oc ON n.EmployeeID = oc.Nurse
    WHERE oc.RoomNumber = 122;
END;
CALL SP_Nurses_122();

DELIMITER ;
