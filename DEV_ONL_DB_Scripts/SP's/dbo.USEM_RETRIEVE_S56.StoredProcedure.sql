/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S56]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S56] (  
 @Ac_First_NAME         CHAR(16),  
 @Ac_Last_NAME          CHAR(20),  
 @An_County_IDNO        NUMERIC(3, 0),  
 @Ai_RowFrom_NUMB       INT=1,  
 @Ai_RowTo_NUMB         INT=10  
  
 )  
AS  
 /*  
  *     PROCEDURE NAME    : USEM_RETRIEVE_S56  
  *     DESCRIPTION       : Retrieve Last Name, First Name, Worker Idno, and County Code for an Office Code, County Code, First Name, Last Name, and Worker Idno that?s common between two tables.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-MAR-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
  DECLARE @Ld_High_DATE   DATE = '12/31/9999',
          @Ld_Current_DATE  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  
  
  SELECT t.Last_NAME,  
         t.First_NAME,  
         t.Worker_ID,  
         t.County_IDNO,  
         t.County_NAME,      
         t.RowCount_NUMB  
    FROM (SELECT m.Last_NAME,  
                 m.First_NAME,  
                 m.Worker_ID,  
                 m.County_IDNO,  
                 m.County_NAME,  
                 m.RowCount_NUMB,  
                 m.Rec_NUMB  
            FROM (SELECT k.Last_NAME,  
                         k.First_NAME,  
                         k.Worker_ID,  
                         k.County_IDNO,  
                         k.County_NAME,  
                         COUNT(1) OVER() AS RowCount_NUMB,  
                         k.ORD_rownum AS Rec_NUMB  
                FROM( SELECT  LTRIM(X.Last_NAME) AS Last_NAME,  
                          LTRIM(X.First_NAME) AS First_NAME,  
                          X.Worker_ID,  
                          X.County_IDNO,  
                          X.County_NAME,  
                         ROW_NUMBER() OVER( ORDER BY X.First_NAME, X.Last_NAME) AS ORD_ROWNUM    
                        FROM (SELECT u.Last_NAME,  
                                     u.First_NAME,  
                                     u.Worker_ID AS Worker_ID,  
                                     d.County_IDNO AS County_IDNO,  
                                     c.County_NAME AS County_NAME  
                                    FROM UASM_Y1 n  
                                     JOIN OFIC_Y1 d  
                                      ON (n.Office_IDNO = d.Office_IDNO)  
                                     JOIN USEM_Y1 u  
                                      ON (u.Worker_ID = n.Worker_ID)  
                                     JOIN COPT_Y1 c  
                                      ON (d.County_IDNO = c.County_IDNO)  
                               WHERE n.EndValidity_DATE = @Ld_High_DATE 
                                 AND n.Expire_DATE > @Ld_Current_DATE
                                 AND n.Effective_DATE <= @Ld_Current_DATE     
                                 AND d.County_IDNO = ISNULL(@An_County_IDNO,d.County_IDNO)  
                                 AND d.EndValidity_DATE = @Ld_High_DATE 
                                 AND u.BeginEmployment_DATE <=@Ld_Current_DATE  
                                 AND u.EndEmployment_DATE = @Ld_High_DATE  
                                 AND u.EndValidity_DATE = @Ld_High_DATE  
                                 AND u.First_NAME >= ISNULL(@Ac_First_NAME, u.First_NAME)
                                 AND u.Last_NAME = ISNULL(@Ac_Last_NAME, u.Last_NAME)
	                           ) AS X  ) AS k) AS m  
           WHERE m.Rec_NUMB <= @Ai_RowTo_NUMB) AS t  
   WHERE Rec_NUMB >= @Ai_RowFrom_NUMB  
   ORDER BY Rec_NUMB;  
 END; --END OF USEM_RETRIEVE_S56  


GO
