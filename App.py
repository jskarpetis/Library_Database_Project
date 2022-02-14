from logging import  error
import streamlit as st
from DBManager import DBManager
from DBEmployeeUsers import Employee,ClearData
import numpy as np
from PIL import Image

DBPath = "Database/LibNetwork.db" # Database default path

st.set_page_config(layout="wide") # Change inner property of streamlit for wider main window 
st.sidebar.title("Welcome to LibNet") 

# Initialize in sidebar login form and store the employee credentials
email = st.sidebar.text_input("Email")
ssn = st.sidebar.text_input("SSN")

if st.sidebar.checkbox("Login") and email and ssn:
    # if user wrote the credentials and clicked on login Log him in
    Manager = DBManager(DBPath) # Initialize a Manager that speaks with our DB
    Emp = Employee("JP@gmail.com",23080002895,Manager) # Initialize the Employee object 

    # Menu of sidebar
    menu = st.sidebar.radio("Options",('Home','Book','Customer'))

    if menu == "Home":
        # If home is clicked (also default mode) 
        inf = Emp.Info() # get the employee information 

        st.subheader(f"Welcome {inf[0]} {inf[1]}") # Welcoming 
        st.write("**Employee Information**")

        Labels = ["Name","Surname","Email","SSN","Section","Library","Hours_Of_Work"] 
        image = Image.open('Photos/Icon.jpg')
        EmployeeContainer = st.columns([2,2,2]) # Break down the main window into 3 columns for represantation

        EmployeeContainer[0].image(image, caption='Employee Photo') # A photo for the employee

        for blank in range(3): # Forming context
            EmployeeContainer[1].write(" ")
            EmployeeContainer[2].write(" ")

        for i in range(len(Labels)): # Writing Context in the columns 2-3 
            if i == 4 or i == 5:
                EmployeeContainer[1].write(Labels[i])
                EmployeeContainer[2].write(str(inf[i]["Name"]) + " | ID: " + str(inf[i]["ID"]) )
            else:
                EmployeeContainer[1].write(Labels[i])
                EmployeeContainer[2].write(inf[i])

    elif menu == "Book":
        # if Book is selected 
        st.subheader("Manage Library Books") 
        BookMenu = st.radio("Book Section",('Show Books','Add Book','Update Book','Delete Book','Inter Loaning')) # Here are some additional options for the book

        if BookMenu == "Show Books":
            # if employee wants to see all the Books 
            results = []
            fbv_string = ""

            filters = st.columns(2) # formating by seperating window into columns
            filters_by_value = st.columns(4)

            filters[0].write("**Filter**")
            filter_option = filters[0].selectbox("Choose showcase filter",('Library','Section')) # selectbox for dynamic selection of Books (All books of his library or all Book of his Section)
            filter_ = 0 if filter_option == 'Library' else 1  # Define Filter 1 

            filters[1].write("**Fields**")
            # multiselect for which fields of the Book Entity he wants to see
            fields = filters[1].multiselect("Choose fields to display",['Title','ISBN','Author','Publisher','Availability','Condition']) 

            filters_by_value[0].write("**Filter by value**")
            # multiselect if he want to search for specific books with specific characteristics
            filter_by_value = filters_by_value[0].multiselect("Choose specific values",['Title','Author','Publisher']) 
            
            if filter_by_value:
                # For each specific filter he choose get an input from him for filtering 
                for indx in range(0,len(filter_by_value)) :
                    filters_by_value[indx+1].write(f"**{filter_by_value[indx]}**")
                    results.append(filters_by_value[indx+1].text_input(f"Enter {filter_by_value[indx]}"))

            st.subheader("Books Showcase")

            if fields:
                # make a fbv string which is the form that Employee.showBook expects
                for length in range(len(results)):fbv_string = fbv_string + f" {filter_by_value[length]} = '{results[length]}' and"
                fbv_string = fbv_string[:-3]
                DataArray = np.array(Emp.showBook(filter_,fields,fbv_string)) # Call showBooks of Employee
                st.write(DataArray)
            
        elif BookMenu == "Add Book":
            # If Add Book is selected
            st.subheader("Add a Book in the Library") 

            cols = st.columns(3) # formating

            CategoriesTable = Manager.SELECT("Category","Category_Name,Category_ID",f"Section_ID = '{Emp.Section['ID']}'") # find the category ID of employee Section

            # Take all the fields for the Book to be inserted
            Title = cols[0].text_input("Add the title of the Book")
            Publisher = cols[0].text_input("Publisher")
            Category_ID = cols[0].selectbox("Category",ClearData(CategoriesTable)) # Define ID by the choice of user
            Submit = cols[0].button("Submit")

            ISBN = cols[1].text_input("ISBN")
            Availability = cols[1].selectbox("Availability",("True","False"))
            Availability = "" if Availability=="False" else "True"

            Author = cols[2].text_input("Author")
            Condition = cols[2].selectbox("Condition",("Good","Medium","Bad"))
            
            Category_ID = [content[1] for content in CategoriesTable if content[0]==Category_ID][0]
            
            if Submit :
                try:
                    Emp.addBook(Title,ISBN,Author,Publisher,Availability,Condition,Category_ID) #Insert the Book in DB
                    st.write("Congratulations, You successfully add a new Book.")
                except error as e :
                    st.write(e)

        elif BookMenu == "Update Book":
            st.subheader("Update a Book from Library")

            S_results = []
            C_results = []
            con_string = ""
            set_string = ""
            TwoColumnOrder = st.columns(2)
            ThreeColumnOrder = st.columns(6)
            Submit = st.button("Submit")

            Setter = TwoColumnOrder[0].multiselect("Setters",['Title','ISBN','Author','Publisher','Availability','Condition','Category_ID']) # Multiselect for setter
            Condition = TwoColumnOrder[1].multiselect("Conditions",['Book Title','Book Category_ID','Book ISBN','Book Author','Book Publisher','Book Availability','Book Condition']) # multiselect conditions

            if Setter :
                #getting setter in the rigth form
                S_results = [ThreeColumnOrder[indx%3].text_input(f"Enter {Setter[indx]}") for indx in range(0,len(Setter))] 
                for length in range(len(S_results)):set_string = set_string + f" {Setter[length]} = '{S_results[length]}' and" if Setter[length] not in ('Category_ID','ISBN') else set_string + f" {Setter[length]} = {S_results[length]} and"
                set_string = set_string[:-3]

            if Condition :
                #getting conditions in the right form 
                C_results = [ThreeColumnOrder[3+(indx%3)].text_input(f"Enter {Condition[indx]}") for indx in range(0,len(Condition))]
                for length in range(len(C_results)):con_string = con_string + f" {Condition[length]} = '{C_results[length]}' and" if Condition[length] not in ('Book Category_ID','Book ISBN') else con_string + f" {Condition[length]} = {C_results[length]} and"
                con_string = con_string[:-3]
                con_string = con_string.replace("Book ","")
            
            if Submit:
                try:
                    Emp.updateBook(set_string,con_string) # calling updateBook of Employee
                    st.write("Congratulations, Book is up to date.")
                except error as e :
                    st.write(e)
                
        elif BookMenu == "Delete Book":
            st.subheader("Delete a Book from Library")

            C_results = []
            con_string = ""
            TwoColumnOrder = st.columns(2)
            ThreeColumnOrder = st.columns(3)
            Submit = st.button("Submit")

            Condition = TwoColumnOrder[0].multiselect("Conditions",['Title','ISBN','Author','Publisher','Availability','Condition','Category_ID']) # multiselect for conditions of delete

            if Condition :
                C_results = [ThreeColumnOrder[(indx%3)].text_input(f"Enter {Condition[indx]}") for indx in range(0,len(Condition))]
                for length in range(len(C_results)):con_string = con_string + f" {Condition[length]} = '{C_results[length]}' and" if Condition[length] not in ('Category_ID','ISBN') else con_string + f" {Condition[length]} = {C_results[length]} and"
                con_string = con_string[:-3]
                con_string = con_string.replace("Book ","")
            
            if Submit and Condition:
                try:
                    st.write(con_string)
                    Emp.deleteBook(con_string)
                    st.write("Congratulations, Book is deleted.")
                except error as e :
                    st.write(e)
        
        elif BookMenu == 'Inter Loaning':
            #Inter Library Loaning 
            '''Please be careful with this option,NEED TO BE FIXED this option takes only books that library 1 dosent have at all (isbn is not contained in library id 1) '''
            isbn = st.text_input("isbn")
            quantity = st.text_input("quantity")

            submit = st.button("Submit")

            if submit:
                st.write(Emp.InterLibLoan(isbn,int(quantity)))
        
        Manager.close() # close manager no need to keep it open it will reopen if another choice has been done

    elif menu == "Customer":
        st.subheader("Manage Library Books") 
        CustomerMenu = st.radio("Book Section",('Lend a Book','New Order','New warning')) 

        if CustomerMenu == 'Lend a Book':
            st.subheader("Lend a Book from Library")

            C_email = st.text_input("Please Enter Customer Email")
            Book_Title = st.text_input("Title")
            Submit = st.button("Submit")

            if Submit:
                values = Emp.LendBook(C_email,Book_Title)
                st.write(values)
        
        elif CustomerMenu == 'New Order':
            st.write("**This Option coming really soon**")
        
        elif CustomerMenu == 'New warning':
            st.write("**This Option coming really soon**")
        
        Manager.close()

else:
    # Unable to login user --> wrong credentials or he didnt input the credentials yet welcome him as a guest and dont let him do anything
    st.subheader("Welcome Guest")
    st.write("Please **Login** with your **Employee Credentials**")
            

