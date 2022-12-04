CREATE DATABASE Library_Management_System -- Creating Database for Library
USE Library_Management_System -- Activating Database

SELECT * FROM Author
SELECT * FROM Book
SELECT * FROM Customer
SELECT * FROM Fine
SELECT * FROM Issue
SELECT * FROM Submit

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'submit'

-- 1 : issue book

-- Required : 
--		Customer_ID: 10 (used below)   => to which customer book is being issued
--		book_id: 10  (used below)      => which book is being issued
-- with above 2 vakues, we can issue book using query below

-- checking if this customer already have same book Issued
IF EXISTS (SELECT * FROM issue WHERE customer_id = 12 and book_id = 101)
	PRINT('Same Book Already Issued To Customer.')

ELSE
	IF EXISTS (SELECT * FROM book WHERE book_id = 101 AND stock > 0) -- if Book Exists & In Stock
       AND EXISTS(SELECT * FROM customer WHERE customer_id = 12 AND customer_Status = 'Active') -- if Customer is Registered Member
		BEGIN	
			PRINT('Book Available & Customer Active');
			
			INSERT INTO issue --Creating Record       
			VALUES(12,101, CAST( GETDATE() AS Date) , DATEADD(day, 7, CAST( GETDATE() AS Date)), 'Issued');
						   -- issue date : Today Date	-- due date : 7 Days post Issue date
			PRINT('Book Issued Successfully.');

			UPDATE book -- Updating Stock 
			SET stock = (stock-1)
			WHERE Book_ID = 101
			PRINT('Stock Updated');
		END
	ELSE -- TroubleShooting : Root Cause Analysis for Management
		BEGIN
			IF EXISTS (SELECT * FROM book WHERE book_id = 101 AND stock > 0) PRINT('book available') 
				ELSE PRINT('book not available') -- checking Book Availibility

			IF EXISTS(SELECT * FROM customer WHERE customer_id = 12 AND customer_Status = 'Active') PRINT('customer active')  
				ELSE PRINT('customer not registered/Active') -- Checking Cusomer Status
		END



		--------------------

-- checking if this customer already have same book Issued
IF EXISTS (SELECT * FROM issue WHERE customer_id = 15 and book_id = 101)
	PRINT('Same Book Already Issued To Customer.')

ELSE
	IF EXISTS (SELECT * FROM book WHERE book_id = 101 AND stock > 0) -- if Book Exists & In Stock
       AND EXISTS(SELECT * FROM customer WHERE customer_id = 15 AND customer_Status = 'Active') -- if Customer is Registered Member
		BEGIN	
			PRINT('Book Available & Customer Active');
			
			INSERT INTO issue --Creating Record       
			VALUES(15,101, CAST( GETDATE() AS Date) , DATEADD(day, 7, CAST( GETDATE() AS Date)), 'Issued');
						   -- issue date : Today Date	-- due date : 7 Days post Issue date
			PRINT('Book Issued Successfully.');

			UPDATE book -- Updating Stock 
			SET stock = (stock-1)
			WHERE Book_ID = 101
			PRINT('Stock Updated');
		END
	ELSE -- TroubleShooting : Root Cause Analysis for Management
		BEGIN
			IF EXISTS (SELECT * FROM book WHERE book_id = 101 AND stock > 0) PRINT('book available') 
				ELSE PRINT('book not available') -- checking Book Availibility

			IF EXISTS(SELECT * FROM customer WHERE customer_id = 15 AND customer_Status = 'Active') PRINT('customer active')  
				ELSE PRINT('customer not registered/Active') -- Checking Cusomer Status
		END

		select * from submit
		--------------------
--  return book 

-- Required : 
--		Issue ID : 32 (used below) => only Issue ID is required to Return book and Update Fine (if applicable)

IF NOT EXISTS (SELECT  * FROM issue WHERE issue_id = 31 )  -- checking if same Book issued or not
	print('Book Not Identified')

ELSE
	BEGIN
		PRINT('Book Identified');

		INSERT INTO submit -- Returing Book with Today date
		VALUES(31, CAST( GETDATE() AS Date),'Returned');
		PRINT('Book Returned');

		UPDATE book -- Updating Stock Availability
		SET stock = (stock+1)
		WHERE Book_ID = (SELECT Book_ID FROM issue WHERE Issue_ID=31);
		PRINT('Stock Updated');


		-- creating null record in fine
		INSERT INTO fine
		VALUES((SELECT Return_ID FROM submit WHERE Issue_ID=31), -- fetchin respective Return ID
				-- calculating number of weeks book owned 
				DATEDIFF(WEEK, (SELECT issue_date FROM issue WHERE Issue_ID=31), -- fetching book issue date
					(SELECT return_date FROM submit WHERE Issue_ID=31)) -- fetching book return date
				, NULL, -- null record for fine (updated next)
				'Returned'  );
		PRINT('Record Created in Fine');

		-- updating fine = 0 if book was returned before/ on due date 
		IF ((SELECT weeks_owned FROM fine WHERE Return_ID = (SELECT Return_ID FROM Submit WHERE Issue_ID=31 )) = 0 )
			BEGIN
				UPDATE fine
				SET Fine_Amount = 0
				WHERE Return_ID = (SELECT Return_ID FROM Submit WHERE Issue_ID=31 )
			END
		-- updating fine = 100* extra weeks owned
		ELSE
			BEGIN
				UPDATE fine
				SET Fine_Amount = (Weeks_Owned-1)*100
				WHERE Return_ID = (SELECT Return_ID FROM Submit WHERE Issue_ID=31 )
			END
		PRINT('Fine Updated');
	END



-- updated return code which matches book as well

	------------------
	-- Required : 
--		Issue ID : 32 (used below) => only Issue ID is required to Return book and Update Fine (if applicable)
--      Book ID  : 101 (used below) => used to match if Same book is being returned as issued
-- with above 2 values, we can return book & update fine dynamically using query below


IF NOT EXISTS (SELECT  * FROM issue WHERE issue_id = 32 )  -- checking if Customer Issued Book or Not
	print('Book Not Identified')

ELSE
	BEGIN

		IF((SELECT book_id FROM issue WHERE issue_id = 32) = (SELECT 101)) -- checking if returning same book which was issued 
		-- fetching book id from Issue table			      -- book id being returned
		BEGIN
			PRINT('Book Identified');
		
			INSERT INTO submit -- Returing Book with Today date
			VALUES(32, (SELECT Customer_ID FROM issue WHERE Issue_ID = 32) 
				   ,(SELECT due_date FROM issue WHERE Issue_ID = 32) 
				   ,CAST( GETDATE() AS Date),'Returned');

			PRINT('Book Returned');

			UPDATE book -- Updating Stock Availability
			SET stock = (stock+1)
			WHERE Book_ID = (SELECT Book_ID FROM issue WHERE Issue_ID=32);
			PRINT('Stock Updated');


			-- creating null record in fine
			INSERT INTO fine
			VALUES((SELECT Return_ID FROM submit WHERE Issue_ID=32), -- fetching respective Return ID
					(SELECT Customer_ID FROM issue WHERE Issue_ID = 32) , -- fetching respective Customer ID
					-- calculating number of weeks book owned 
					DATEDIFF(WEEK, (SELECT issue_date FROM issue WHERE Issue_ID=32), -- fetching book issue date
						(SELECT return_date FROM submit WHERE Issue_ID=32)) -- fetching book return date
					, NULL, -- null record for fine (updated next)
					'Returned'  );
			PRINT('Record Created in Fine');

			-- updating fine = 0 if book was returned before/ on due date 
			IF ((SELECT weeks_owned FROM fine WHERE Return_ID = (SELECT Return_ID FROM Submit WHERE Issue_ID=32 )) = 0 )
				BEGIN
					UPDATE fine
					SET Fine_Amount = 0
					WHERE Return_ID = (SELECT Return_ID FROM Submit WHERE Issue_ID=32 )
				END
			-- updating fine = 100* extra weeks owned
			ELSE
				BEGIN
					UPDATE fine
					SET Fine_Amount = (Weeks_Owned-1)*100
					WHERE Return_ID = (SELECT Return_ID FROM Submit WHERE Issue_ID=32 )
				END
			PRINT('Fine Updated');

		END
		ELSE
			PRINT('Please Return Same Book As Issued')

	END


select * from fine
	------------------










-- for all borrowers
SELECT f.Customer_ID, c.Customer_Name, SUM(f.Fine_Amount) AS Fine_Due 
FROM fine f
INNER JOIN Customer c
ON f.customer_ID = c.Customer_ID 
GROUP BY f.customer_ID, c.Customer_Name
ORDER BY Fine_Due DESC

-- for those only who have some fine due
SELECT f.Customer_ID, c.Customer_Name, SUM(f.Fine_Amount) AS Fine_Due 
FROM fine f
INNER JOIN  Customer c
ON f.customer_ID = c.Customer_ID 
GROUP BY f.customer_ID, c.Customer_Name
HAVING SUM(f.fine_amount) > 0
ORDER BY Fine_Due DESC

-- fine due for a specific customer

-- fine due 
-- Required : 
--		Customer Name
SELECT f.customer_ID, c.Customer_Name, SUM(f.Fine_Amount) AS Fine_Due
FROM fine f
INNER JOIN customer c
ON f.customer_ID = c.Customer_ID 
GROUP BY f.customer_ID, c.Customer_Name
HAVING c.Customer_Name = 'Krati Tripathi'


-- fine due 
-- Required : 
--		Customer ID
SELECT f.customer_ID, c.Customer_Name, SUM(f.Fine_Amount) AS Fine_Due
FROM fine f
INNER JOIN  customer c
ON f.customer_ID = c.Customer_ID 
GROUP BY f.customer_ID, c.Customer_Name
HAVING f.Customer_ID = 11



-- stock of available books
SELECT b.Book_ID , a.author_name, b.Title, b.Stock
FROM Book b
INNER JOIN Author a
ON a.Author_ID = b.Author_ID


update book
set stock = stock -1
where Book_ID = 101


SELECT * FROM Author
SELECT * FROM Book
SELECT * FROM Customer
SELECT * FROM Fine
SELECT * FROM Issue
SELECT * FROM Submit

CREATE TABLE Author
(
	Author_ID INT PRIMARY KEY IDENTITY(1,1),
	Author_Name NVARCHAR(40) NOT NULL UNIQUE
)

CREATE TABLE Book
(
	Book_ID INT PRIMARY KEY IDENTITY(100,1),
	Author_ID INT NOT NULL,
	Title NVARCHAR(40) NOT NULL UNIQUE,
	Genre NVARCHAR(20),
	Published_Year INT,
	Stock INT NOT NULL CHECK(Stock >= 0),
	FOREIGN KEY(Author_ID) REFERENCES Author(Author_ID)
)

CREATE TABLE Customer
(
	Customer_ID INT PRIMARY KEY IDENTITY(10,1),
	Customer_Name NVARCHAR(40) NOT NULL,
	Join_Date DATE,
	Customer_Status NVARCHAR(15) NOT NULL
)

CREATE TABLE fine
(
	Fine_ID INT PRIMARY KEY IDENTITY(10,1),
	Return_ID INT NOT NULL,
	Customer_ID INT NOT NULL,
	Weeks_Owned INT NOT NULL,
	Fine_Amount INT NOT NULL,
	Statuss NVARCHAR(10),
	FOREIGN KEY(Customer_ID) REFERENCES Customer(Customer_ID)
)

CREATE TABLE Issue
(
	Issue_ID INT PRIMARY KEY IDENTITY(10,1),
	Customer_ID INT NOT NULL,
	Book_ID INT NOT NULL,
	Issue_Date DATE NOT NULL,
	Due_Date DATE,
	Statuss NVARCHAR(10),
	FOREIGN KEY(Customer_ID) REFERENCES Customer(Customer_ID)
)


CREATE TABLE Submit
(
	Return_ID INT PRIMARY KEY IDENTITY(10,1),
	Customer_ID INT NOT NULL,
	Issue_ID INT NOT NULL,
	Due_Date DATE,
	Return_Date DATE NOT NULL,
	Statuss NVARCHAR(10),
	FOREIGN KEY(Customer_ID) REFERENCES Customer(Customer_ID)
)





-- Trouble Shooting Steps
if exists (select * from book where book_id = 101 and stock > 0) print('book available') else print('book not available') 

if exists(select * from customer where customer_id = 10 and customer_Status = 'Active') print('customer active')  else print('customer not registered/Active') 

TO MAKE FOR ALL OF THEM


delete from submit
where issue_ID = 31
	

select * from Submit

alter table submit
alter column return_date date





--------------------------------------------- VIEWS TO EXTRACT INFORMATION ----------------------------------------

SELECT * FROM Book -- entire employee table
SELECT * FROM Author -- entire employee_contact table
SELECT * FROM customer -- entire organisation details
SELECT * FROM Issue -- employees having Multiple Contact
SELECT * FROM Submit -- employees having Multiple Email
SELECT * FROM Fine -- employees having Multiple Contact with Count
SELECT * FROM vw_allFineDue -- Fine Due for All Customers
SELECT * FROM vw_FineDue -- Only customers with some fine due
SELECT * FROM vw_stock -- Stock Availability



