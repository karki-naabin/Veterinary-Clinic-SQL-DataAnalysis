/*Assisting a veterinarian clinic on analysing their data. Their data is dispersed 
across multiple csv files and needs to be uploaded on to database to perform the analytics*/

/*First creating a table for owners info in the database named vetclinic*/
CREATE TABLE owners(
    ownerid INT,
    name VARCHAR(200),
    surname VARCHAR(200),
    streetaddress VARCHAR(250),
    city VARCHAR(250),
    state VARCHAR(100),
    statefull VARCHAR(250),
    zipcode INT,
    PRIMARY KEY (ownerid)
);

/*copying the data from csv file containing owners info into the table*/
COPY owners
FROM 'C:\Users\Lenovo\Desktop\sqldatasets\P9-Owners.csv'
DELIMITER ','
CSV HEADER;

/*Creating a table to store pets info into the database*/
CREATE TABLE pets(
    petid VARCHAR(100),
    petname VARCHAR(250),
    petkind VARCHAR(150),
    petgender VARCHAR(150),
    petage INT,
    petownerid INT,
    PRIMARY KEY (petid),
    CONSTRAINT fk_owners_pets
       FOREIGN KEY (petownerid)
       REFERENCES owners (ownerid)

);

/*copying pets info data from csv file into the table*/
COPY pets
FROM 'C:\Users\Lenovo\Desktop\sqldatasets\P9-Pets.csv'
DELIMITER ','
CSV HEADER;

/*Creating a table to store the procedure details into the database*/
CREATE TABLE procedure_details(
    procedure_type VARCHAR(250),
    procedure_subcode INT,
    procedure_description VARCHAR(250),
    procedure_price INT,
    CONSTRAINT pk_procedure_details PRIMARY KEY (procedure_type,procedure_subcode)
);

/*copying the data from csv file containing procedure details into the table*/
COPY procedure_details
FROM 'C:\Users\Lenovo\Desktop\sqldatasets\P9-ProceduresDetails.csv'
DELIMITER ','
CSV HEADER;

/*creating the table to store procedure performed on pets into the database.*/
CREATE TABLE procedure_history(
    ph_petid VARCHAR(100),
    procedure_date DATE,
    hprocedure_type VARCHAR(250),
    hprocedure_subcode INT,
    CONSTRAINT fk_procedureh_pdetails
      FOREIGN KEY (hprocedure_type,hprocedure_subcode)
      REFERENCES procedure_details(procedure_type,procedure_subcode)
);

/*changing default datestyle of postgresql to datestyle in csv file*/
SET datestyle To ISO,MDY;

/*copying the details about procedure performed on pets from csv file into the table*/
COPY procedure_history
FROM 'C:\Users\Lenovo\Desktop\sqldatasets\P9-ProceduresHistory.csv'
DELIMITER ','
CSV HEADER;

/*Extracting information on pets names and owner names side by side */
SELECT o.ownerid, o.name, o.surname, pt.petname, pt.petkind
FROM owners o
JOIN pets pt
ON o.ownerid=pt.petownerid;

/*Finding out which pets from the clinic has procedure performed*/
SELECT ph.*
FROM procedure_history ph
JOIN pets pt
ON ph.ph_petid=pt.petid;

/*Matching up all the procedures performed to their descriptions*/
SELECT pd.procedure_description, ph.*
FROM procedure_history ph
JOIN procedure_details pd
ON pd.procedure_type=ph.hprocedure_type AND pd.procedure_subcode =ph.hprocedure_subcode ;

/*same as above but only or pets from the clinic in question*/
SELECT pd.procedure_description, ph.*
FROM procedure_history ph
JOIN pets pt
ON ph.ph_petid=pt.petid
JOIN procedure_details pd
ON pd.procedure_type=ph.hprocedure_type AND pd.procedure_subcode =ph.hprocedure_subcode ;


/*Extracting the data of individual costs(procedure prices) incurred by owners of pets from the 
clinic in question(data containg owner names and prices )*/
SELECT o.ownerid,o.name, o.surname,SUM(pd.procedure_price) AS procedure_price
FROM owners o
JOIN pets pt
ON o.ownerid=pt.petownerid
JOIN procedure_history ph
ON ph.ph_petid=pt.petid
JOIN procedure_details pd
ON pd.procedure_type=ph.hprocedure_type AND pd.procedure_subcode =ph.hprocedure_subcode
GROUP BY 1,2;
