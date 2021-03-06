/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S115]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S115](
     @An_Case_IDNO		 NUMERIC(6,0)
     )                 
AS  
  
/*  
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S115  
 *     DESCRIPTION       : It retrieves the Current Charge Detail For the Case.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
     BEGIN  
  
    
     
      
      DECLARE  
         @Ld_High_DATE           DATE = '12/31/9999',
         @Lc_TypeDebtI_CODE      CHAR(1)='I'  ,
         @Li_One_NUMB			 INT=1,
         @Li_Two_NUMB		     INT=2,
         @Ld_Systemdatetime_DTTM DATETIME =DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
         
        SELECT X.TypeDebt_CODE , 
               X.FreqPeriodic_CODE,
               X.Periodic_AMNT, 
               CONVERT(VARCHAR,X.AccrualNext_DATE ,101) AS AccrualNext_DATE,
               SUBSTRING (DATENAME(WEEKDAY,X.AccrualNext_DATE),1,3)AS AccrualNext_TEXT
         FROM(  
            SELECT O.TypeDebt_CODE, 
                   MAX(dbo.BATCH_COMMON$SF_GET_AMT_FOR_LOWEST_FREQ(O.Case_IDNO, O.TypeDebt_CODE, DBO.BATCH_COMMON$SF_GET_LOWEST_FREQ(O.Case_IDNO, O.TypeDebt_CODE))) AS Periodic_AMNT,
                   MAX(dbo.BATCH_COMMON$SF_GET_LOWEST_FREQ(O.Case_IDNO, O.TypeDebt_CODE)) AS FreqPeriodic_CODE, 
                   MIN(O.AccrualNext_DATE) AS AccrualNext_DATE  
            FROM OBLE_Y1 O 
            WHERE   
               O.Case_IDNO = @An_Case_IDNO    
               AND SUBSTRING(O.TypeDebt_CODE, @Li_Two_NUMB, @Li_One_NUMB) != @Lc_TypeDebtI_CODE    
               AND CONVERT(DATE,@Ld_Systemdatetime_DTTM) BETWEEN O.BeginObligation_DATE AND O.EndObligation_DATE    
               AND O.EndValidity_DATE = @Ld_High_DATE  
            GROUP BY O.TypeDebt_CODE  
         )  AS X;
                    
END;--End of OBLE_RETRIEVE_S115   
  



GO
