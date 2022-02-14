/*Finds customers that have borrowed and what books they have borrowed*/
SELECT Book."Title", Book."ISBN", Book."Author", Book."Category_ID", NESTED."First_Name", NESTED."Last_Name"
    FROM Book, (SELECT Customer."First_Name", Customer."Last_Name", "Book_ID" 
                    FROM Customer, Borrowing_Contains_Books 
                    WHERE Customer."Customer_ID"=Borrowing_Contains_Books."Customer_Borrowing_ID" 
                        AND Customer."Customer_ID"=2) AS NESTED
    WHERE Book."Book_ID"=NESTED."Book_ID";


/*Finds customers that have borrowed and returned in time */
SELECT * FROM Customer, (SELECT * 
                            FROM Borrowing 
                            WHERE julianday(Borrowing."End_Date") > julianday(Borrowing."Final_End_Date")) AS NESTED
        WHERE Customer."Customer_ID"=NESTED."Customer_ID";


/*Finds all available books in all libraries*/
SELECT * FROM Book WHERE Book."Availability"=1;


/*Finds all available specific books(with certain isbn)*/
SELECT * FROM Book WHERE Book."Availability"=1 AND book."ISBN"=9789609400251;


/*Finds all available books in all sections of all libraries*/
SELECT Section."Section_ID", NESTED."Title", Nested.availability FROM 
    Section, 
    (SELECT * FROM Book, Category WHERE Book."Availability"=1 AND Book."Category_ID"=Category."Category_ID") AS NESTED
    WHERE Section."Section_ID"=NESTED."Section_ID";


/*Finds all books in a specific category_id*/
SELECT * FROM Book WHERE Book."Category_ID"=2;


/*Finds all books with good condition*/
SELECT * FROM Book WHERE Book."Condition"="Good";


/*Finds the count of all books in all libraries*/
SELECT Book."Title", COUNT(*) FROM Book GROUP BY Book."ISBN" 


/*Finds all the books in all libraries, their section and the category they belong to*/
SELECT Library."Library_Name", DOUBLENESTED."Title", DOUBLENESTED."Section_Name", DOUBLENESTED."Category_Name"
    FROM Library, (SELECT * 
                    FROM Section, (SELECT * FROM Book JOIN Category ON Book."Category_ID"=Category."Category_ID") AS NESTED 
                    WHERE Section."Section_ID"=NESTED."Section_ID") AS DOUBLENESTED
    WHERE Library."Library_ID"=DOUBLENESTED."Library_ID";


/*Finds books that are in maintenance and their reason to be*/
SELECT Book."Book_ID", Book."Title", Book."ISBN", Maintenance."Maintainance_Type" 
    FROM Book, Maintenance 
    WHERE Book."Book_ID"=Maintenance."Book_ID";


/*Finds all books with certain publisher*/
SELECT * FROM Book WHERE Book."Publisher"="Τζιόλα";


/*Finds all books that have 2 or more copies*/
SELECT Book."Title", COUNT(*) FROM Book GROUP BY Book."ISBN" HAVING COUNT(*)>=2; 


/*Finds all customers that have borrowed books*/
SELECT * FROM Customer, Borrowing WHERE Customer."Customer_ID"=Borrowing."Customer_ID";


/*Finds all customer orders, which book is ordered and by what customer*/
SELECT * 
    FROM Book, (SELECT Customer."First_Name", Customer."Last_Name", "Book_ID", "Date_Of_Order"
                    FROM Customer, Customer_Orders_Book 
                    WHERE Customer."Customer_ID"=Customer_Orders_Book."Customer_ID") AS NESTED
    WHERE Book."Book_ID"=NESTED."Book_ID";
        

/*Finds all customer orders but not the details of the books ordered*/
SELECT * FROM Customer, Customer_Orders_Book WHERE Customer."Customer_ID"=Customer_Orders_Book."Customer_ID";


/*Finds all customers that have borrowed & have not returned & and are late on the return of the borrowing*/
SELECT * 
    FROM Customer, Borrowing 
    WHERE Customer."Customer_ID"=Borrowing."Customer_ID"  
        AND Borrowing."Final_End_Date"	IS NULL 
        AND julianday(Borrowing."End_Date") < julianday(datetime('now'));


/*Finds all the customers that have borrowed and returned*/
SELECT * 
    FROM Customer, Borrowing 
    WHERE Customer."Customer_ID"=Borrowing."Customer_ID" AND Borrowing."Final_End_Date" IS NOT NULL;


/*Finds all customers and their membership data*/
SELECT * FROM Customer, Customer_Membership WHERE Customer."Customer_ID"=Customer_Membership."Customer_ID";


/*Finds all the customers that have paid for their membership and details*/
SELECT Customer."First_Name", Customer."Last_Name", Customer_Membership."Payment", Customer_Membership."Title"
    FROM Customer, Customer_Membership 
    WHERE Customer."Customer_ID"=Customer_Membership."Customer_ID" AND Customer_Membership."Payment"!=0;


/*Finds customers with specific type of membership*/
SELECT Customer."First_Name", Customer."Last_Name", Customer."Email", Customer_Membership."Title"
    FROM Customer, Customer_Membership 
    WHERE Customer."Customer_ID"=Customer_Membership."Customer_ID" AND 
        Customer_Membership."Title"="Gold Membership";


/*Finds employee contract information & employee details*/
SELECT Employee."First_Name", Employee."Last_Name", Employee_Contract."Standard_Payment", Employee_Contract."Employee_Job", Employee_Contract."Days_Off"
    FROM Employee, Employee_Contract 
    WHERE Employee.Employee_ID=Employee_Contract."Employee_ID";


/*Finds all employees that have taken a vacation for any reason*/
SELECT Employee."First_Name", Employee."Last_Name", Employee_Day_Off."Description", Employee_Day_Off."Start_Date", Employee_Day_Off."End_Date"
    FROM Employee, Employee_Day_Off 
    WHERE Employee."Employee_ID"=Employee_Day_Off."Employee_ID";


/*Finds all employees that are not managers*/
SELECT * FROM Employee WHERE Employee."Mgr_ID" IS NOT NULL;


/*Finds all managers*/
SELECT Employee.Employee_ID, Employee.First_Name, Employee.Last_Name, Employee.Email
    FROM Employee WHERE Employee."Mgr_ID" IS NULL;


/*Finds for all interlibrary loans who is the sender and what is the book that is being sent*/
SELECT NESTED."Library_ID", NESTED."Library_Name", NESTED."Book_ID", Book."Title", Book."ISBN" 
    FROM Book, (SELECT Library."Library_ID", Library."Library_Name", Inter_Library_Loaning."Book_ID", Inter_Library_Loaning."Quantity"
                    FROM Inter_Library_Loaning, Library 
                    WHERE Inter_Library_Loaning."Library_Sender"=Library."Library_ID") AS NESTED
    WHERE Book."Book_ID"=NESTED."Book_ID";


/*Finds for all libraries all the available books*/
SELECT NESTED."Library_Name", Book."Title", Book."ISBN", Book."Author"
    FROM Book, (SELECT Library."Library_Name", Library_Contains_Books."Book_ID" 
                    FROM Library, Library_Contains_Books 
                    WHERE Library."Library_ID"= Library_Contains_Books."Library_ID") AS NESTED
    WHERE Book."Book_ID"=NESTED."Book_ID" 
        AND Book."Availability"=1;


/*Finds all books for all libraries*/
SELECT NESTED."Library_Name", Book."Title", Book."ISBN", Book."Author"
    FROM Book, (SELECT Library."Library_Name", Library_Contains_Books."Book_ID" 
                    FROM Library, Library_Contains_Books 
                    WHERE Library."Library_ID"= Library_Contains_Books."Library_ID") AS NESTED
    WHERE Book."Book_ID"=NESTED."Book_ID";
        

/*Finds all the customers of a specific library*/
SELECT Library."Library_ID", Library."Library_Name", Customer."First_Name", Customer."Last_Name", Customer."Email"
    FROM Customer, Library
    WHERE Customer."Library_ID"=Library."Library_ID"
        AND Library."Library_ID"=1;


/*Finds all payments executed by any library*/
SELECT Library."Library_Name", Employee_Payment."Payment_With_Insurance", Employee_Payment."Bonus", Employee_Payment."FPA"
    FROM Library, Employee_Payment 
    WHERE Employee_Payment."Library_ID"=Library."Library_ID";


/*Finds all math books in all libraries*/
SELECT Book."Title", Book."Author", Book."ISBN", Book."Availability", Category."Category_Name"	
    FROM Book, Category 
    WHERE Book."Category_ID"=Category."Category_ID" 
        AND Category."Category_Name"="Μαθηματικά";


/*Finds all the employees that have been by the library they work at*/
SELECT Employee."Employee_ID", Employee."First_Name", Employee."Last_Name", Employee_Payment."Payment_With_Insurance", Employee_Payment."Library_ID"
    FROM Employee, Employee_Payment 
    WHERE Employee."Employee_ID"=Employee_Payment."Employee_ID";


/*Finds all the categories of books in all libraries and the section they belong to*/
SELECT Category."Category_Name", Section."Section_Name"
    FROM Category, Section
    WHERE Category."Section_ID"=Section."Section_ID";


/*Finds for library with specific id what customers have borrowed books and which are those books*/
SELECT * 
    FROM Book, (SELECT Customer."Library_ID", Customer."First_Name", Customer."Last_Name", NESTED."Book_ID"
                    FROM Customer, (SELECT Borrowing."Customer_ID", Borrowing_Contains_Books."Book_ID"
                                        FROM Borrowing, Borrowing_Contains_Books
                                        WHERE Borrowing."Customer_ID"=Borrowing_Contains_Books."Customer_Borrowing_ID") AS NESTED
                    WHERE Customer."Customer_ID"=NESTED."Customer_ID" AND Customer."Library_ID"=1) AS DOUBLENESTED
    WHERE Book."Book_ID"=DOUBLENESTED."Book_ID"
                    

/*Finds the max books that a customer can borrow according to their membership*/
SELECT Customer."First_Name", Customer."Last_Name", Customer_Membership."Max_Books", Customer_Membership."Title"
    FROM Customer, Customer_Membership 
    WHERE Customer."Customer_ID"=Customer_Membership."Customer_ID";


/*Finds for a specific employee(id) the library they work & the section they work at & the books that are in their working section*/

SELECT TRIPLENESTED."Library_Name", TRIPLENESTED."First_Name", TRIPLENESTED."Last_Name", DOUBLENESTED."Title" FROM (SELECT Section."Section_ID", NESTED."Title"
                    FROM Section, (SELECT * FROM Book, Category 
                                        WHERE Book."Category_ID"=Category."Category_ID") AS NESTED
                    WHERE Section."Section_ID"=NESTED."Section_ID") AS DOUBLENESTED,
                (SELECT Library."Library_Name", Employee."First_Name", Employee."Last_Name", Employee."Section_ID"
                    FROM Employee, Library 
                    WHERE Employee."Library_Work_ID"=Library."Library_ID"
                        AND Employee."Employee_ID"=23080002895) AS TRIPLENESTED
        WHERE DOUBLENESTED."Section_ID"=TRIPLENESTED."Section_ID"


/*Finds for all interlibrary loans who is the sender and who is the receiver NOTE: can find which book is sent aswell*/
SELECT Library."Library_Name" AS RECEIVER_NAME, NESTED."SENDER_NAME"
    FROM Library, (SELECT INTR."Library_Getter", Library."Library_Name" AS SENDER_NAME 
                        FROM Inter_Library_Loaning AS INTR, Library 
                         WHERE INTR."Library_Sender"=Library."Library_ID") AS NESTED
    WHERE Library."Library_ID"=NESTED."Library_Getter";


/*Finds books with a specific author in all libraries*/
SELECT NESTED."Library_Name", Book."Title", Book."ISBN", Book."Author", Book."Condition"
    FROM Book, (SELECT Library."Library_Name", Library_Contains_Books."Book_ID" 
                    FROM Library, Library_Contains_Books 
                    WHERE Library."Library_ID"= Library_Contains_Books."Library_ID") AS NESTED
    WHERE Book."Book_ID"=NESTED."Book_ID" 
        AND NESTED."Library_Name"="Βιβλιοθήκη & Κέντρο Πληροφόρησης, Πανεπιστήμιο Πατρών"
        AND Book."Availability"=1 
        AND Book."Author"="Alexander Charles K., Sadiku Matthew N. O.";
        

/*Finds the count of categories in each section of all libraries*/
SELECT Library."Library_Name", NESTED."Section_ID", NESTED."CATEGORIES_IN_SECTION"
    FROM Library, (SELECT *, COUNT() AS CATEGORIES_IN_SECTION 
                            FROM Category, Section 
                            WHERE Category."Section_ID"=Section."Section_ID"
                            GROUP BY Category."Section_ID") AS NESTED
        WHERE Library."Library_ID"=NESTED."Library_ID";











        



        







































