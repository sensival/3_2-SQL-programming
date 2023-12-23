USE leeminseonDB;

CREATE TABLE userTBL
(
    userID CHAR(8) NOT NULL,
    name NVARCHAR(10) NOT NULL,
	birthday DATE,
	age AS DATEDIFF(YEAR, birthday, GETDATE()),
	sex NCHAR(2) NOT NULL,
	addr NVARCHAR(255) NOT NULL,
	mobile1 CHAR(3) NOT NULL,
	mobile2 CHAR(8) NOT NULL,
	email VARCHAR(50)

);
CREATE TABLE buyTBL
(
    orderNum INT NOT NULL,
	orderDate DATE NOT NULL,
	userID CHAR(8) NOT NULL,
	prodName NCHAR(10) NOT NULL,
	price INT NOT NULL,
	amount INT NOT NULL,
	category NVARCHAR(10)

);

ALTER TABLE userTBL
ADD CONSTRAINT PK_userTBL PRIMARY KEY (userID);


ALTER TABLE buyTBL
ADD CONSTRAINT FK_buyTBL_userTBL FOREIGN KEY (userID) REFERENCES userTBL(userID);

GO
INSERT INTO userTBL VALUES('lee', '�̹μ�', '1987-08-22', '��','���� ������', '011', '11111111', 'aaa@naver.com');
INSERT INTO userTbl VALUES('kim', '������', '1979-08-22', '��','�泲 ���ؽ�', '011', '2222222',  'bbb@naver.com');
INSERT INTO userTbl VALUES('park', '�ڹ���', NULL, '��','���� ������', '019', '3333333',  'ccc@naver.com');
INSERT INTO userTbl VALUES('son', '�����', '1950-08-22', '��','��� ������', '011', '4444444',  'ddd@naver.com');
INSERT INTO userTbl VALUES('jin', '������', '1979-08-22', '��','���� ���ϱ�', '011', '5555555' ,  'eee@naver.com');
INSERT INTO userTbl VALUES('kang', '������', NULL, '��','���� ������', '016', '6666666',  'fff@naver.com');
INSERT INTO userTbl VALUES('choi', '�ֿ���', '1969-08-22', '��','�泲 ����', '011', '7777777', NULL);
INSERT INTO userTbl VALUES('jeong', '�����', '1972-08-22', '��','��� �ȵ���', '011', '8888888',  NULL);
INSERT INTO userTbl VALUES('yang', '�絿��', '1965-08-22', '��', '��� ���ֽ�', '018', '9999999',  'ggg@naver.com');
INSERT INTO userTbl VALUES('yoo', '������', '1973-08-22', '��','���� ���빮��', '010', '0000000',  'hhh@naver.com');

GO
INSERT INTO buyTBL VALUES(1,'2022-10-01','kim' , '������', 3000, 5,'����');
INSERT INTO buyTbl VALUES(2,'2022-11-01','lee', '����', 4000, 10, '����');
INSERT INTO buyTbl VALUES(3,'2023-12-01','jeong', '����', 500, 20, NULL);
INSERT INTO buyTbl VALUES(4,'2023-01-01','yang', '���Į', 12000, 3, NULL);
INSERT INTO buyTbl VALUES(5,'2023-02-01','kang', '����', 500, 100, '����');
INSERT INTO buyTbl VALUES(6,'2023-03-01','park', '��ø', 1000, 50 , '����');
INSERT INTO buyTbl VALUES(7,'2023-04-01','yoo', '�޸���' ,1500, 30 , '����');
INSERT INTO buyTbl VALUES(8,'2023-05-01','choi', '�̾���' ,10000, 1, '����');
INSERT INTO buyTbl VALUES(9,'2023-06-01','choi', 'û����', 30000, 2, '�Ƿ�');
INSERT INTO buyTbl VALUES(10,'2023-07-01','son', '�ȭ', 60000, 1, '�Ƿ�');
INSERT INTO buyTbl VALUES(11,'2023-08-01','kim', 'å' , 19900, 5, '����');
INSERT INTO buyTbl VALUES(12,'2023-09-01','son', '�ȭ', 60000, 2, '�Ƿ�');

SELECT * FROM userTBL;
SELECT * FROM buyTBL;

--����1: ���� ���� Ƚ��(GROUPBY)
SELECT userID, count(*) AS [�ֹ� Ƚ��] from buyTBL GROUP BY userID;

--����2: 'yang'�� ���ų����� �̸�, �ּ�, email ��ȸ(INNERJOIN)
SELECT name, buyTBL.userID, orderDate, prodName, addr, mobile1 + mobile2 AS [����ó], email
   FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID 
			WHERE buyTBL.userID='yang';

--����3: ���űݾ� TOP 3 ��ǰ(TOP, ORDERBY)
SELECT TOP(3) prodName,SUM(price * amount) AS [�ѱ��ž�] 
	from buyTBL GROUP BY prodName  ORDER BY SUM(price * amount) DESC;

--����4: ���� ���űݾ� ���(CAST)
SELECT sex, ROUND(AVG(CAST(price * amount AS float)), 0) AS [���űݾ����]
	FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID
			GROUP BY sex ;

--����5: ��, �� ��ǰ�з��� ����Ƚ��(PIVOT)
SELECT * FROM
	(SELECT sex,orderNum, COALESCE(category, 'NULL') AS category
		FROM  buyTBL
		 INNER JOIN userTBL
			 ON buyTBL.userID = userTBL.userID)
				AS SourceTable
PIVOT (
    count(orderNum)
    FOR category IN ([����], [����], [����], [�Ƿ�], [����], [NULL])
) AS PivotTable;

--����6: ��� ȸ�������� ���ų���(OUTERJOIN)
SELECT *
   FROM userTBL
    FULL OUTER JOIN buyTBL
        ON buyTBL.userID = userTBL.userID ;

--����7: ������ ���űݾ� (ROLLUP)
SELECT LEFT(addr, 2) AS [����], SUM(price * amount) AS [�ѱ��ž�]
 	FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID
GROUP BY ROLLUP(LEFT(addr, 2));

--����8: ���űݾ� ���� ȸ������(RANK)
SELECT RANK( ) OVER(ORDER BY SUM(price * amount) DESC)[���űݾ׼���], name, SUM(price * amount) AS[���űݾ�]
   FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID
			GROUP BY name;

--����9: email ���� ����� �����ϰ� ��ȸ(EXCEPT)
SELECT * FROM userTBL
	EXCEPT
	SELECT * FROM userTBL WHERE email IS NULL;

--����10: ���ž׼��� ���� �� ���(CASE~END)
SELECT U.userID, U.name, SUM(B.price*B.amount) AS [�ѱ��ž�],
	CASE	
		WHEN ( SUM(B.price*B.amount) >= 100000) THEN '�ֿ����'
		WHEN ( SUM(B.price*B.amount) >= 50000) THEN '�����'
		WHEN ( SUM(B.price*B.amount) >= 1) THEN '�Ϲݰ�'
		ELSE '�̱��Ű�'
	END AS [�����]
FROM buyTBL B
	 RIGHT OUTER JOIN userTBL  U
		on	B.userID = U.userID
GROUP BY U.userID, U.name
ORDER BY SUM(B.price*B.amount) DESC;