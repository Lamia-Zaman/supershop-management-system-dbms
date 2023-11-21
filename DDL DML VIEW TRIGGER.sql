drop table DEPARTMENT                     cascade constraints;
drop table EMPLOYEEPOSITION               cascade constraints;
drop table EMPLOYEE                       cascade constraints;
drop table EMPLOYEEPHONE                  cascade constraints;
drop table SUPPLIER                       cascade constraints;
drop table SUPPLIERPHONE                  cascade constraints;
drop table PRODUCT                        cascade constraints;
drop table SUPPLIERPRODUCTREL             cascade constraints;
drop table CUSTOMER                       cascade constraints;
drop table BILL                           cascade constraints;
drop table BILLPRODUCTREL                 cascade constraints;
drop view  FORSUPPLIERS;
set linesize 200
set pagesize 100

create table department(
deptID int,
category varchar(10),
managerID int,
primary key(deptID)
);

create table employeeposition(
position varchar(10),
salary int,
primary key(position)
);

create table employee(
employeeID int,
name varchar(20),
position varchar(10),
deptID int,
primary key(employeeID),
foreign key(deptID) references department(deptID),
foreign key(position) references employeeposition(position)
);


create table employeephone(
employeeID int,
phone int,
foreign key(employeeID) references employee(employeeID)
);

create table supplier(
supplierID int,
name varchar(20),
address varchar(10),
primary key(supplierID)
);

create table supplierphone(
supplierID int,
phone int,
foreign key(supplierID) references supplier(supplierID)
);

create table product(
productID int,
name varchar(20),
price int,
deptid int,
CurrentQuantity int,
Quantity_Remark varchar(20),
primary key(productID),
foreign key(deptID) references department(deptID)
);


create table supplierproductrel(
supplyID int,
supplyprice int,
suppliedamount int,
supplierID int,
productID int,
primary key(supplyID),
foreign key(supplierID) references supplier(supplierID),
foreign key(productID) references product(productID)
);

create table customer(
customerID int,
name varchar(20),
DOB date,
email varchar(20),
primary key(customerID)
);

create table bill(
billID int,
TotalGrandPrice int,
EmployeeID int,
CustomerID int,
primary key(billID),
foreign key(EmployeeID) references employee(EmployeeID),
foreign key(CustomerID) references customer(CustomerID)
);

create table billproductrel(
billID int,
productID int,
cost int,
quantity int,
totalprice int,
foreign key(billID) references bill(billID),
foreign key(productID) references product(productID)
);


insert into department(deptid,category) values(1,'Dairy');
insert into department(deptid,category) values(2,'Clothing');
insert into department(deptid,category) values(3,'Cosmetics');
insert into department(deptid,category) values(4,'Grocery');

insert into employeeposition values('Manager', 20000);
insert into employeeposition values('Cashier', 15000);
insert into employeeposition values('StockClerk', 2000);
insert into employeeposition values('Cleaner', 1000);

insert into employee values(1001,'A','Manager',1);
update department set managerid=1001 where deptid=1;

insert into employee values(1002,'B','Cashier',1);
insert into employee values(1003,'C','Manager',2);
update department set managerid=1003 where deptid=2;

insert into employee values(1004,'D','Cashier',2);
insert into employee values(1005,'E','Cleaner',1);


insert into employeephone values(1001,111111);
insert into employeephone values(1001,111112);
insert into employeephone values(1001,111113);
insert into employeephone values(1002,331111);
insert into employeephone values(1003,114411);
insert into employeephone values(1003,115761);
insert into employeephone values(1005,341111);

insert into supplier values(5001,'X','Gollamari');
insert into supplier values(5002,'Y','Daulatpur');
insert into supplier values(5003,'Z','Moylapota');

insert into supplierphone values(5001,555555);
insert into supplierphone values(5002,666666);
insert into supplierphone values(5003,777777);
insert into supplierphone values(5002,888888);

insert into product values(1,'Milk',60,1,7,'LOW');
insert into product values(2,'Kurti',300,2,8,'LOW');
insert into product values(3,'Egg',15,1,2,'LOW');
insert into product values(4,'Kajal',100,3,0,'LOW');
insert into product values(5,'Rice',80,4,10,'OKAY');
insert into product values(6,'Panjabi',500,2,10,'OKAY');
insert into product values(7,'Saree',5000,2,20,'OKAY');

insert into supplierproductrel values(1,50,100,5001,1);
insert into supplierproductrel values(2,5,200,5002,3);
insert into supplierproductrel values(3,40,200,5002,1);

insert into customer values(6001,'AA',DATE '2000-01-01','a@gmail.com');
insert into customer values(6002,'BB',DATE '2000-05-04','b@gmail.com');
insert into customer values(6003,'CC',DATE '1999-01-01','c@gmail.com');
insert into customer values(6004,'DD',DATE '1998-01-05','d@gmail.com');
insert into customer values(6005,'EE',DATE '1959-02-02','e@gmail.com');
alter session set nls_date_format='YYYY-MM-DD';

--trigger to calculate totalprice per product
create or replace trigger totalpriceTrigger 
before insert
on billproductrel
for each row
BEGIN
select price
into :new.cost
from product
where :new.productid=productid;
:new.totalprice:= :new.quantity*:new.cost;
update product set product.currentquantity=product.currentquantity-:new.quantity where productid=:new.productid;
end;
/

--trigger to increase product when supplier supplies product
create or replace trigger ProductIncreaseTrig
before insert
on supplierproductrel
for each row
BEGIN
update product set product.currentquantity=product.currentquantity+:new.suppliedamount where productid=:new.productid;
end;
/

--trigger to show quantity status low if product quantity falls below 10
create or replace trigger statusTrigger 
before update
on product
for each row
BEGIN
if :new.currentquantity<10 then :new.quantity_remark:='LOW';
else :new.quantity_remark:='OKAY';
END IF;
end;
/

--trigger to find out grand total price of a bill receipt
create or replace trigger grandtotalTrigger 
after insert 
on billproductrel
for each row
BEGIN
update bill set bill.totalgrandprice=0 where bill.totalgrandprice is NULL;
update bill set bill.totalgrandprice=bill.totalgrandprice+:new.totalprice where bill.billid=:new.billid;
end;
/

insert into bill(billID,employeeID,customerID) values(1,1002,6001);
insert into billproductrel(billID,productID,quantity) values(1,1,1);
insert into billproductrel(billID,productID,quantity) values(1,3,2);
insert into billproductrel(billID,productID,quantity) values(1,5,1);

insert into bill(billID,employeeID,customerID) values(2,1004,6002);
insert into billproductrel(billID,productID,quantity) values(2,1,1);

insert into bill(billID,employeeID,customerID) values(3,1004,6003);
insert into billproductrel(billID,productID,quantity) values(3,1,1);

insert into bill(billID,employeeID,customerID) values(4,1002,6004);
insert into billproductrel(billID,productID,quantity) values(4,1,1);

insert into bill(billID,employeeID,customerID) values(5,1004,6002);
insert into billproductrel(billID,productID,quantity) values(5,1,2);

select * from  DEPARTMENT                      ;
select * from  EMPLOYEEPOSITION                ;
select * from  EMPLOYEE                        ;
select * from  EMPLOYEEPHONE                   ;
select * from  SUPPLIER                        ;
select * from  SUPPLIERPHONE                   ;
select * from  PRODUCT                         ;
select * from  SUPPLIERPRODUCTREL              ;
select * from  CUSTOMER                        ;
select * from  BILL                            ;
select * from  BILLPRODUCTREL                  ;

--some important sqls used in real world
--find out which category contains which product
select department.category, product.name from department natural join product;


--check the product increasing when supplier supplies product
select * from product;
insert into supplierproductrel values(4,10,200,5002,3);
select * from supplierproductrel;
select * from product;


--find out how products decrease  and costs are calculated automatically if one buys product
select * from product;
select * from bill;
select * from billproductrel;
insert into bill(billID,employeeID,customerID) values(6,1002,6001);
insert into billproductrel(billID,productID,quantity) values(6,7,11);
select * from product;
select * from bill;
select * from billproductrel;

--send data to suppliers on which product is low in quantity
create view forsuppliers as
select name, quantity_remark from product where quantity_remark='LOW';
select * from forsuppliers;

