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
INSERT INTO userTBL VALUES('lee', '이민선', '1987-08-22', '여','서울 성동구', '011', '11111111', 'aaa@naver.com');
INSERT INTO userTbl VALUES('kim', '김의중', '1979-08-22', '남','경남 김해시', '011', '2222222',  'bbb@naver.com');
INSERT INTO userTbl VALUES('park', '박미정', NULL, '여','전남 목포시', '019', '3333333',  'ccc@naver.com');
INSERT INTO userTbl VALUES('son', '손흥민', '1950-08-22', '남','경기 수원시', '011', '4444444',  'ddd@naver.com');
INSERT INTO userTbl VALUES('jin', '진강훈', '1979-08-22', '여','서울 강북구', '011', '5555555' ,  'eee@naver.com');
INSERT INTO userTbl VALUES('kang', '강지영', NULL, '남','서울 강남구', '016', '6666666',  'fff@naver.com');
INSERT INTO userTbl VALUES('choi', '최영란', '1969-08-22', '여','경남 양산시', '011', '7777777', NULL);
INSERT INTO userTbl VALUES('jeong', '정재곤', '1972-08-22', '남','경북 안동시', '011', '8888888',  NULL);
INSERT INTO userTbl VALUES('yang', '양동빈', '1965-08-22', '여', '경기 여주시', '018', '9999999',  'ggg@naver.com');
INSERT INTO userTbl VALUES('yoo', '유동빈', '1973-08-22', '남','서울 동대문구', '010', '0000000',  'hhh@naver.com');

GO
INSERT INTO buyTBL VALUES(1,'2022-10-01','kim' , '복숭아', 3000, 5,'과일');
INSERT INTO buyTbl VALUES(2,'2022-11-01','lee', '포도', 4000, 10, '과일');
INSERT INTO buyTbl VALUES(3,'2023-12-01','jeong', '감자', 500, 20, NULL);
INSERT INTO buyTbl VALUES(4,'2023-01-01','yang', '장미칼', 12000, 3, NULL);
INSERT INTO buyTbl VALUES(5,'2023-02-01','kang', '볼펜', 500, 100, '문구');
INSERT INTO buyTbl VALUES(6,'2023-03-01','park', '수첩', 1000, 50 , '문구');
INSERT INTO buyTbl VALUES(7,'2023-04-01','yoo', '메모지' ,1500, 30 , '문구');
INSERT INTO buyTbl VALUES(8,'2023-05-01','choi', '이어폰' ,10000, 1, '전자');
INSERT INTO buyTbl VALUES(9,'2023-06-01','choi', '청바지', 30000, 2, '의류');
INSERT INTO buyTbl VALUES(10,'2023-07-01','son', '운동화', 60000, 1, '의류');
INSERT INTO buyTbl VALUES(11,'2023-08-01','kim', '책' , 19900, 5, '서적');
INSERT INTO buyTbl VALUES(12,'2023-09-01','son', '운동화', 60000, 2, '의류');

SELECT * FROM userTBL;
SELECT * FROM buyTBL;

--쿼리1: 고객별 구매 횟수(GROUPBY)
SELECT userID, count(*) AS [주문 횟수] from buyTBL GROUP BY userID;

--쿼리2: 'yang'의 구매내역과 이름, 주소, email 조회(INNERJOIN)
SELECT name, buyTBL.userID, orderDate, prodName, addr, mobile1 + mobile2 AS [연락처], email
   FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID 
			WHERE buyTBL.userID='yang';

--쿼리3: 구매금액 TOP 3 제품(TOP, ORDERBY)
SELECT TOP(3) prodName,SUM(price * amount) AS [총구매액] 
	from buyTBL GROUP BY prodName  ORDER BY SUM(price * amount) DESC;

--쿼리4: 성별 구매금액 평균(CAST)
SELECT sex, ROUND(AVG(CAST(price * amount AS float)), 0) AS [구매금액평균]
	FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID
			GROUP BY sex ;

--쿼리5: 남, 여 제품분류별 구매횟수(PIVOT)
SELECT * FROM
	(SELECT sex,orderNum, COALESCE(category, 'NULL') AS category
		FROM  buyTBL
		 INNER JOIN userTBL
			 ON buyTBL.userID = userTBL.userID)
				AS SourceTable
PIVOT (
    count(orderNum)
    FOR category IN ([과일], [문구], [전자], [의류], [서적], [NULL])
) AS PivotTable;

--쿼리6: 모든 회원내역과 구매내역(OUTERJOIN)
SELECT *
   FROM userTBL
    FULL OUTER JOIN buyTBL
        ON buyTBL.userID = userTBL.userID ;

--쿼리7: 지역별 구매금액 (ROLLUP)
SELECT LEFT(addr, 2) AS [지역], SUM(price * amount) AS [총구매액]
 	FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID
GROUP BY ROLLUP(LEFT(addr, 2));

--쿼리8: 구매금액 높은 회원순위(RANK)
SELECT RANK( ) OVER(ORDER BY SUM(price * amount) DESC)[구매금액순위], name, SUM(price * amount) AS[구매금액]
   FROM buyTBL
     INNER JOIN userTBL
        ON buyTBL.userID = userTBL.userID
			GROUP BY name;

--쿼리9: email 없는 사람들 제외하고 조회(EXCEPT)
SELECT * FROM userTBL
	EXCEPT
	SELECT * FROM userTBL WHERE email IS NULL;

--쿼리10: 구매액수에 따른 고객 등급(CASE~END)
SELECT U.userID, U.name, SUM(B.price*B.amount) AS [총구매액],
	CASE	
		WHEN ( SUM(B.price*B.amount) >= 100000) THEN '최우수고객'
		WHEN ( SUM(B.price*B.amount) >= 50000) THEN '우수고객'
		WHEN ( SUM(B.price*B.amount) >= 1) THEN '일반고객'
		ELSE '미구매고객'
	END AS [고객등급]
FROM buyTBL B
	 RIGHT OUTER JOIN userTBL  U
		on	B.userID = U.userID
GROUP BY U.userID, U.name
ORDER BY SUM(B.price*B.amount) DESC;