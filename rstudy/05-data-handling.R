#data 불러오기
data("mtcars")
?mtcars

#데이터의 앞부분 확인
head(mtcars) #기본 6개 행
head(mtcars, n=10)

#데이터의 뒷부분 확인
tail(mtcars)
tail(mtcars, n=1) #가장 마지막 행

#데이터의 형식
is(mtcars)

#컬럼 이름과 행 이름을 확인
colnames(mtcars)
rownames(mtcars)

#실제 데이터의 모양 확인
View(mtcars)

#데이터의 생김새(차원) 정보
dim(mtcars)

#데이터의 구조 확인 -> 변수명과 관측치의 수 등을 확인
str(mtcars)

#요약 통계량 확인 :summary
summary(mtcars)

#특정 변수의 요약 통계량 확인
summary(mtcars$mpg) #연비 정보의 요약 통계량
#mtcars의 mpg변수 요약통계량 중 1사분위수, 3사분위수를 추출
summary(mtcars$mpg)[c("1st Qu.","3rd Qu.")]
#특정 변수(mpg, wt) 요약통계량 확인
summary(mtcars[c("mpg", "wt")])
#특정 컬럼을 배제한 나머지 변수의 통계량 확인(3, 5컬럼 제외)
summary(mtcars[c(-3,-5)])

#wt 변수의 boxplot
boxplot(mtcars$wt,mtcars$mpg)

#wt 변수를 가지고 outlier 확인
#wt의 중앙값을 확인
wt.median <-median(mtcars$wt)
wt.median
wt.1q <- summary(mtcars$wt)['1st Qu.'] #1사분위수
wt.1q
wt.3q <-summary(mtcars$wt)['3rd Qu.'] #3사분위수
wt.3q
wt.iqr <- wt.3q -wt.1q #IQR
wt.iqr
names(wt.iqr) <-"IQR"
wt.iqr
#1사분위수에서 IQR *1.5를 빼면 하단 극단치 경계
wt.1q -wt.iqr *1.5
# 3사분위수에서 IQR *1.5를 더하면 상단 극단치 경계
wt.3q +wt.iqr *1.5
#mtcars$wt 중에서 상단 극단치 경계를 넘어가는 값을 뽑아보기
mtcars$wt > wt.3q + wt.iqr *1.5 #상단 극단치 여부
mtcars$wt < wt.1q -wt.iqr*1.5 #하단 극단치 여부 판별

#실제 중량이 극단치를 넘어가는 자동차 정보를 추출
outliers <-mtcars$wt[mtcars$wt >wt.3q + wt.iqr*1.5]
outliers

IQR(mtcars$wt) == wt.iqr


#연습
#wstudents.xls 를 불러와서 데이터 프레임으로 확인을 해 봅시다
#테이블의 구조 확인 
#테이블의 사이즈를 확인
#앞 뒤 10개의 데이터를 확인
# 요약 통계량을 확인해 봅시다

library(readxl)
wstudents <-read_excel("wstudents.xlsx", sheet=1)
wstudents

str(wstudents) #구조
dim(wstudents) #사이즈
head(wstudents, n=10)
tail(wstudents, 10)
summary(wstudents)


#연습
#seoul_pop_2017_3-4.xlsx 불러오기
#seoul_cctv.xlsx불러오기
#정제
#자치구를 기준으로 merge 수행
#rda 저장
#bar chart로 출력


library(readxl) #엑셀패키지 로드
seoul.pop <-read_excel("seoul_pop_2017_3-4.xls", sheet=1, skip=3)
seoul.pop
seoul.pop[,2:6]
seoul.pop.filtered <-seoul.pop[, 2:6]
seoul.pop.filtered
str(seoul.pop.filtered)
colnames(seoul.pop.filtered)<- c("자치구", "세대","계", "남자", "여자")
seoul.pop.filtered
save(seoul.pop.filtered, file="seoul.pop.filtered.rda")

#CCTV 데이터 불러오기
seoul.cctv <- read_excel("seoul_cctv.xlsx", sheet=1)
seoul.cctv

seoul.cctv[, 1:2]
seoul.cctv.filtered <-seoul.cctv[, 1:2]
save(seoul.cctv.filtered, file="seoul.cctv.filtered.rda")

colnames(seoul.cctv.filtered)
colnames(seoul.pop.filtered)

colnames(seoul.cctv.filtered) <- c("자치구", "CCTV 수")
seoul.cctv.filtered
str(seoul.cctv.filtered)
# CCTV 수 컬럼이 숫자가 아니라 chr로 되어있다 ->변경
seoul.cctv.filtered[[2]] <-as.numeric(seoul.cctv.filtered[[2]])
str(seoul.cctv.filtered)

#두 데이터를 병합 by ="자치구"
seoul.merged <-merge(seoul.pop.filtered, seoul.cctv.filtered, by ="자치구")
seoul.merged

# 저장
save(seoul.merged, file="seoul_pop_cctv.rda")

#seoul.merged 순위를 매겨 봅시다
seoul.merged[order(seoul.merged[6]),]
#역순 정렬
seoul.merged[order(-seoul.merged[6]),]

#파생변수
seoul.merged$PERCCTV <- seoul.merged[6] / seoul.merged[3]
seoul.merged

save(seoul.merged, file="seoul_pop_cctv.rda")

#막대그래프 그리기
seoul.merged[3]
barplot(seoul.merged[[3]] / 1000, main="서울 자치구별 인구 분포", names.arg= seoul.merged[1],
        col=rainbow(nrow(seoul.merged)),las=2, xlab="자치구", ylab="인구(천명)")

#막대그래프 그리기
#인구당 CCTV 대수 그래프
barplot(seoul.merged[[6]]/ seoul.merged[[3]], name.arg=seoul.merged$자치구, las=2, main="서울 자치구 인구당 CCTV 대수",
        col="Purple", border="blue", xlab="자치구", ylab="인구당 CCTV")



#데이터 전처리 :dplyr
install.packages("dplyr")
library(dplyr)

# 데이터 불러오기
scores <-read.csv("class_scores.csv")
#데이터 셋 확인
head(scores)
tail(scores)
str(scores) #구조 확인
summary(scores) #통계량 확인

#filter :조건에 맞는 행 선택 -sql의 where절과 비슷
#grade가 1인 학생
scores$grade ==1
scores[scores$grade ==1,] #기본방식

filter(scores, grade == 1) #dplyr 방식
head(filter(scores, grade ==1)) #타 함수와의 조합

#gender가 F인 데이터를 추출
scores[scores$gender =='F',] #기본 방식
filter(scores, gender =='F') # dplyr

#조건이 여러 개일 경우 논리 연산자로 조합
#grade가 1이고 등급이 B인 학생들
filter(scores, grade ==1 & class == 'B')
#writing 점수가 80점 이상이거나, English 점수가 80점 이상인학생
filter(scores, English >= 80 | Writing >=80)

#조건에 여러 개의 값을 비교 %in%
#grade가 3이고 class가 'A' 혹은 'E'인 학생들
filter(scores, grade == 3& class %in% c("A","E"))

#SELECT : 데이터 셋으로부터 특정 변수를 추출(projection)
#scores로부터 Math, English, Writing점수만 추출
select(scores, Math, English, Writing)
#scores로부터 stu_Id, grade, class를 제외한 나머지
# 컬럼- > 제외: -
select(scores, -Stu_ID, -grade, -class)

#특정 범위의 컬럼만 추출 -> :
select(scores, Math:Writing)

#filter와 select 이용, 성별이 F이고 grade가 3인 학생들의 stu_id와 점수정보들을 출력

select(filter(scores, gender == 'F' & grade ==3),c(Stu_ID, Math:Writing)) #함수와 함수의 조합

#mutate :파생 변수의 생성
#scores 데이터 셋에서 Math ~Writing 점수를 합산 ->TOtal 변수 파생
#                                               ->AVG 변수를 파생
mutate(scores,Total=Math +English +Science + Marketing +Writing,
              AVg=(Math +English +Science+ Marketing +Writing)/5)

#연습문제
#scores에서 grade ==1 이고 gender ==F인 데이터 추출
#Total, Avg 파생
#Math, English, Science, Marketing, Writing 제외
# 나머지 컬럼만 선택
#scores.refined 변수에 할당

#방법 1 :순차 실행
temp.filtered <- filter(scores, gender == 'F' & grade == 1)
temp.filtered

temp.mutate <- mutate(temp.filtered, Total =Math +English +Science +Marketing +Writing,
                                     Avg=(Math +English +Science +Marketing + Writing)/ 5)
temp.mutate
scores.refined <-select(temp.mutate, -c(Math:Writing))
scores.refined

#방법 2 : 함수의 중첩
rm(scores.refined)
scores.refined <- select (
  mutate(
    mutate(
      filter(scores, grade ==1 & gender =='F'), 
      Total = Math +English +Science +Marketing +Writing),
      Avg= Total /5
  ),
  -c(Math:Writing)
)
scores.refined

#방법 3 :chain Operator %>%
#앞에서 실행된 결과를 뒤쪽 함수의 입력으로 즉시 활용할 수 있다
# 코드 작성이 생각의 흐름과 일치되기때문에 가독성이 높은 코드 작성 가능
rm(scores.refined)
scores.refined <- scores %>% filter(grade ==1 & gender =='F')%>% 
  mutate(Total =Math +English +Science +Marketing +Writing)%>%
  mutate(Avg= Total / 5)%>%
  select(-c(Math:Writing))
scores.refined

#mutate 함수 내에서 조건별로 다른 값을 세팅
#ifelse를 이용한 파생 변수의 추가
scores.report <- scores.refined %>% mutate(Result = ifelse(Avg >=90, "A",
                                                           ifelse(Avg >=80,"B",
                                                                  ifelse(Avg >=70, "C",
                                                                         ifelse(Avg >=60, "D","F"
                                                                            )
                                                                           )
                                                                  )
                                                           )
                                           )
scores.report[,c("Avg","Result")]
str(scores.report)
# scores.report$result 변수는 순서형 변수가 되면 좋을 것
scores.report$Result <- ordered(scores.report$Result, levels = rev(c("A", "B", "c", "D", "F")))
str(scores.report)

#scores.report에서 C이상의 성적을 받을 학생을
#성적순(avg의 역순)으로 출력

scores.report%>%
  arrange(desc(Avg))

#summarise와 group
#scores 수학의 평균
summarise(scores, mean(Math))
#여러 통계치의 출력
summarise(scores, mean.math = mean(Math),
                  mean.english = mean(English),
                  mean.science = mean(Science))
#group_by :데이터 셋을 특정 그룹으로 묶음
#scores 데이터셋 학년별로 1차 그루핑
# class로 2차 그룹핑
scores.group <- scores %>% group_by(grade, class)
head(scores.group)

#scores.group 과목별(math, english, writing) 평균 요약
scores.group %>%
  summarise(mean.math = mean(Math),
            mean.english = mean(English),
            mean.writing= mean(Writing))

#반별 총점 평균구하기
scores %>% 
  group_by(grade, class) %>% 
  mutate(Total= Math+ English +Science +Marketing +Writing)%>%
  summarise(sum_tot = sum(Total),
            mean_tot = mean(Total))%>%
  arrange(desc(mean_tot))%>%
  head(10)
  
#결측치와 이상치
#결측치는 입력되지 않은 데이터
#이상치는 극단적으로 크거나 극단적으로 작은 값
# 결측치와 이상치는 통계결과를 왜곡할수 있으니
# 적절히 처리 후 데이터 분석

library(ggplot2)
#데이터셋 확인
?mpg
#이상치 확인을 위한 boxplot
boxplot(mpg$cty, mpg$hwy)
#cty만 별도로 boxplot 그리고 객체에 할당
bp <-boxplot(mpg$cty)
#R의 그래프 함수들은 결과 데이터를 함께 가지고 있다
#그래프 내부 데이터의 확인
bp$stats
#확인 ->하단 극단치 경계 ==9
#       상단 극단치 경계 ==26
#정상범주 :9~26
str(mpg)

#mpg 데이터 중 model,cty, hwy변수만 추출해서  
#mileage객체로 다시 할당

library(dplyr)
mileage <-mpg%>% select("model", "cty", "hwy")
mileage

#극단치를 뽑아봅시다
outliers <- mileage %>% filter(cty<9| cty>26)
outliers

#cty 연비의 통계
mean(mileage$cty) #16.86897 이상치 포함
#이상치를 결측치로 대체
mileage$cty <- ifelse(mileage$cty <9 | mileage$cty >26,
                      NA, mileage$cty)
mileage$cty
#cty 연비 통계(NA 포함)
mean(mileage$cty, na.rm=T) #16.55895
#결측치가 많은 데이터 셋도 통계를 왜곡할 수 있다
#NA를 다른 데이터의 통계 대표값으로 대체
#결측 빈도수 확인

is.na(mileage$cty)
table(is.na(mileage$cty))

#결측치를 중앙값으로 대체
med <-median(mileage$cty, na.rm = T)
med

mileage$cty <- ifelse(is.na(mileage$cty),
                            med,
                            mileage$cty)
mean(mileage$cty)


#oracle 데이터베이스 연결
#jdbc 연결을 위한 패키지들
install.packages("rJava")
install.packages("DBI")# 데이터베이스 접속 인터페이스
install.packages("RJDBC") # JDBC에 R을 연결 패키지

#라이브러리 로드
library(rJava)
library(DBI)
library(RJDBC)
#ojdbc 드라이버 경로
driver.path <-
  "C:/oraclexe/app/oracle/product/11.2.0/server/jdbc/lib/ojdbc6.jar"

driver <-JDBC(driverClass="oracle.jdbc.driver.OracleDriver",
              classPath=driver.path)
#Connection 얻기
conn <- dbConnect(driver,
                  "jdbc:oracle:thin:@localhost:1521/xe",
                  "hr",
                  "hr")

conn
#테이블 목록 확인
dbListTables(conn)
#employees table읽기
#employees <-dbReadTable(conn, "employees")
#query만들기
query <- "SELECT *FROM employees"
rs <-dbGetQuery(conn, query) #쿼리 실행
rs

str(rs)
#데이터베이스 접속 해제
dbDisconnect(conn)






































