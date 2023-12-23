USE leeminseonDB;

CREATE TABLE userTBL
(
    userID CHAR(8) NOT NULL primary key,
    name NVARCHAR(10) NOT NULL,
	birthday DATE,
	age INT GENERATED ALWAYS AS (TIMESTAMPDIFF(YEAR, birthday, '2023-11-25')) VIRTUAL,
    /*현재 시각을 구하는 함수 NOW(), CURDATE()는 계속 변하는 값이라 MYSQL의 경우 필드값으로 활용할 수 없어 금일날짜로함*/
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
	category NVARCHAR(10),
	FOREIGN KEY (userID) REFERENCES userTBL(userID)
);

INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('lee', '이민선', '1987-08-22', '여','서울 성동구', '011', '11111111', 'aaa@naver.com');
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('kim', '김의중', '1979-08-22', '남','경남 김해시', '011', '2222222',  'bbb@naver.com');
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('park', '박미정', NULL, '여','전남 목포시', '019', '3333333',  'ccc@naver.com');
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('son', '손흥민', '1950-08-22', '남','경기 수원시', '011', '4444444',  'ddd@naver.com');
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('jin', '진강훈', '1979-08-22', '여','서울 강북구', '011', '5555555' ,  'eee@naver.com');
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('kang', '강지영', NULL, '남','서울 강남구', '016', '6666666',  'fff@naver.com');
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('choi', '최영란', '1969-08-22', '여','경남 양산시', '011', '7777777', NULL);
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('jeong', '정재곤', '1972-08-22', '남','경북 안동시', '011', '8888888',  NULL);
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('yang', '양동빈', '1965-08-22', '여', '경기 여주시', '018', '9999999',  'ggg@naver.com');
INSERT INTO userTBL(userID, name, birthday, sex, addr, mobile1, mobile2, email) 
	VALUES('yoo', '유동빈', '1973-08-22', '남','서울 동대문구', '010', '0000000',  'hhh@naver.com');

SELECT * FROM usertbl;

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

/*쿼리1.고객별 구매 횟수 뷰*/
CREATE VIEW v_count
AS
	SELECT userID, count(*) AS '주문 횟수' from buyTBL GROUP BY userID;
    
SELECT * FROM v_count;


/*쿼리2.'yang'의 구매내역과 이름, 주소, email 조회 복합 뷰*/
CREATE VIEW v_yang
AS
	SELECT name, buyTBL.userID, orderDate, prodName, addr, mobile1 + mobile2 AS '연락처', email
	   FROM buyTBL
		 INNER JOIN userTBL
			ON buyTBL.userID = userTBL.userID 
				WHERE buyTBL.userID='yang';
                
SELECT * FROM v_yang;

/*쿼리3.구매금액 TOP 3 제품 뷰*/
CREATE VIEW v_top3 
AS
    SELECT prodName, SUM(price * amount) AS '총구매액' FROM buyTBL
		GROUP BY prodName
			ORDER BY SUM(price * amount) DESC
				LIMIT 3;
                
SELECT * FROM v_top3;
        
        
/* 쿼리4. 'addr'에 index 설정*/
CREATE INDEX idx_userTbl_addr
	ON userTbl (addr);
    
SHOW INDEX FROM userTbl;   
SELECT userID, name FROM userTbl where addr LIKE '경기%';

/* 쿼리5. 'mobile1'과 'mobile2'에 복합 index 설정*/
CREATE INDEX idx_userTbl_mobile
	ON userTbl (mobile1, mobile2);
    
SHOW INDEX FROM userTbl;   
SELECT name, mobile1, mobile2 FROM userTbl where mobile1 = '010';


/* 쿼리6. 'orderNum'에 unique index 설정*/
CREATE UNIQUE INDEX idx_buyTbl_num
	ON buyTbl (orderNum);
    
SHOW INDEX FROM buyTbl;   
SELECT orderDate, prodName FROM buyTbl where orderNum <5 ;


/* 쿼리7. 고객 등급 조회 저장 프로시저*/
DELIMITER //
CREATE PROCEDURE usp_grade(IN p_userName NVARCHAR(10), OUT p_grade NVARCHAR(10))
BEGIN
    DECLARE totalpur INT; -- 총 구매액을 저장할 변수
    
    SELECT COALESCE(SUM(B.price * B.amount), 0) INTO totalpur
    FROM buyTBL B
    RIGHT OUTER JOIN userTBL U ON B.userID = U.userID
    WHERE U.name = p_userName;

    CASE
        WHEN totalpur >= 100000 THEN SET p_grade = '최우수고객';
        WHEN totalpur >= 50000 THEN SET p_grade = '우수고객';
        WHEN totalpur >= 1 THEN SET p_grade = '일반고객';
        ELSE SET p_grade = '미구매고객';
    END CASE;

END //
DELIMITER ;
	
CALL usp_grade('이민선', @result);
SELECT @result AS grade;

/* 쿼리8. 고객의 모든 주문정보 조회 저장 프로시저*/
DELIMITER //
CREATE PROCEDURE usp_ord(IN p_userName NVARCHAR(10))
BEGIN
SELECT * FROM buyTBL B
    LEFT JOIN  userTBL U ON U.userID = B.userID
		WHERE U.name = p_userName;
END //
DELIMITER ;

CALL usp_ord('최영란');


/* 쿼리9. 전화번호를 seed로 하는 고객 비식별화 함수*/
DELIMITER //
CREATE FUNCTION anonymize(original_name VARCHAR(255), seed INT) RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
    DECLARE randnum INT;
    DECLARE anonyname VARCHAR(255);
    SET randnum = FLOOR(1000 + RAND(seed) * 9000);
    SET anonyname = CONCAT(LEFT(original_name, 1) , '_', randnum);
    RETURN anonyname;
END //
DELIMITER ;

# 이메일이 있는 사용자만 조회
SELECT anonymize(name, CAST(mobile2 AS SIGNED)) AS '비식별화 이름', birthday, sex, addr, mobile1, mobile2 FROM userTBL
	WHERE userID NOT IN (
		SELECT userID FROM userTBL WHERE email IS NULL
	);
    
    
/* 쿼리10. 생일까지 남은 일수 계산 함수*/
DELIMITER //
CREATE FUNCTION howmanyday(birthday DATE) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE today DATE;
    DECLARE next_Bday DATE;
    DECLARE Rdays INT;
    SET today = CURDATE();
    SET next_Bday = STR_TO_DATE(CONCAT(YEAR(today), '-', MONTH(birthday), '-', DAY(birthday)), '%Y-%m-%d');
    
    IF today > next_Bday THEN
        SET next_Bday = STR_TO_DATE(CONCAT(YEAR(today) + 1, '-', MONTH(birthday), '-', DAY(birthday)), '%Y-%m-%d');
    END IF;

    SET Rdays = DATEDIFF(next_Bday, today);

    RETURN Rdays;
END //
DELIMITER ;

SELECT userID, name, birthday, howmanyday(birthday) AS '생일까지 남은 날' FROM userTBL WHERE name='이민선';


/* 쿼리11. 배송 출발 메시지 생성 커서 */
DELIMITER //

CREATE PROCEDURE delivery_Msg()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE userName NVARCHAR(10);
    DECLARE prodName NVARCHAR(10);
	DECLARE delivery_message NVARCHAR(255);
    DECLARE cur_delivery CURSOR FOR
        SELECT U.name, B.prodName
        FROM buyTBL B
        LEFT JOIN userTBL U ON U.userID = B.userID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_delivery;

    FETCH cur_delivery INTO userName, prodName;

    WHILE NOT done DO
		SET delivery_message = CONCAT(userName, '님, ', '주문하신 ', prodName, ' 제품이 배송 출발했습니다.');
        INSERT INTO delmsgbox(delmsg) VALUES (delivery_message) ;
        FETCH cur_delivery INTO userName, prodName;
    END WHILE;

    CLOSE cur_delivery;
END //

DELIMITER ;

CREATE TABLE delmsgbox(
	delmsg NVARCHAR(255)
    );
CALL delivery_Msg();
SELECT * FROM delmsgbox;


/*쿼리12. 나이 최대와 최소 구하는 커서*/
DELIMITER //
CREATE PROCEDURE MaxMin()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE userage INT; 
    DECLARE maxage INT DEFAULT 0; 
    DECLARE minage INT DEFAULT 999; 

    DECLARE maxmincur CURSOR FOR
        SELECT age FROM userTbl;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN maxmincur;

    FETCH maxmincur INTO userage;
    WHILE NOT done DO
        IF userage > maxage THEN
            SET maxage = userage;
        END IF;

        IF userage < minage THEN
            SET minage = userage;
        END IF;

        FETCH maxmincur INTO userage;
    END WHILE;

    CLOSE maxmincur;

    SELECT CONCAT('최대 나이: ', maxage, ', 최소 나이: ', minage) AS result;
END //
DELIMITER ;

CALL MaxMin();

/*쿼리13.물품 주문시 담당직원을 배정하는 트리거 쿼리*/
DELIMITER //
CREATE TRIGGER pack_staff
AFTER INSERT ON buyTbl
FOR EACH ROW
BEGIN
    DECLARE staffnum INT;
    DECLARE staffname NVARCHAR(10);

    SET staffnum = NEW.orderNum % 3;

    IF staffnum = 0 THEN
        SET staffname = '이포장';
    ELSEIF staffnum = 1 THEN
        SET staffname = '김포장';
    ELSE
        SET staffname = '박포장';
    END IF;

    INSERT INTO staff_alloc(staff, orderNum, prodName, amount)
    VALUES (staffname, NEW.orderNum, NEW.prodName, NEW.amount);
END;
//
DELIMITER ;

CREATE TABLE staff_alloc (
    staff NVARCHAR(10), 
    orderNum INT, 
    prodName NCHAR(10),
    amount INT
);

INSERT INTO buyTbl VALUES(13,'2023-11-25','son', '운동화', 60000, 1, '의류');
INSERT INTO buyTbl VALUES(14,'2023-11-26','kim', '책' , 19900, 5, '서적');
INSERT INTO buyTbl VALUES(15,'2023-11-27','son', '운동화', 60000, 2, '의류');

SELECT * FROM staff_alloc;


/*쿼리14. 재고 테이블을 업데이트하는 트리거 쿼리*/
DELIMITER //
CREATE TRIGGER stock_change
AFTER INSERT ON buyTbl
FOR EACH ROW
BEGIN
    UPDATE stock_list SET stockcount = (stockcount - NEW.amount) WHERE prodName = NEW.prodName;
END;
//
DELIMITER ;

CREATE TABLE stock_list (
    prodName NVARCHAR(10), 
    stockcount INT
);

INSERT INTO stock_list VALUES ('복숭아', 100);
INSERT INTO stock_list VALUES ('포도', 100);
INSERT INTO stock_list VALUES ('감자', 100);
INSERT INTO stock_list VALUES ('장미칼', 100);
INSERT INTO stock_list VALUES ('볼펜', 100);
INSERT INTO stock_list VALUES ('수첩', 100);
INSERT INTO stock_list VALUES ('메모지', 100);
INSERT INTO stock_list VALUES ('이어폰', 100);
INSERT INTO stock_list VALUES ('청바지', 100);
INSERT INTO stock_list VALUES ('운동화', 100);
INSERT INTO stock_list VALUES ('책', 100);

INSERT INTO buyTbl VALUES(16,'2023-11-28','lee', '운동화', 60000, 1, '의류');
INSERT INTO buyTbl VALUES(17,'2023-11-29','park', '책' , 19900, 5, '서적');
INSERT INTO buyTbl VALUES(18,'2023-11-30','jin', '청바지', 30000, 2, '의류');

SELECT * FROM stock_list;

