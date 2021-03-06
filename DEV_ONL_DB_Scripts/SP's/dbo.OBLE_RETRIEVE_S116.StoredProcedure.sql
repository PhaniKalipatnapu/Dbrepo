/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S116]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S116]( 
     @An_Case_IDNO		 NUMERIC(6,0),  
     @An_TotFuture_AMNT        NUMERIC(11,2)OUTPUT
     )   
AS                                                       
                                                         
/*  
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S116  
 *     DESCRIPTION       : It Retrieve the current charges for the Case id,TypeDebt Code in Obligation table.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  

   
   
      SET @An_TotFuture_AMNT = NULL;  
  
      DECLARE  
         @Ld_High_DATE DATE = '12/31/9999',
         @Li_One_NUMB			 INT=1,
         @Li_Two_NUMB		     INT=2,  
         @Lc_TypeDebtI_CODE CHAR(1)='I',
          @Ld_Systemdatetime_DTTM DATETIME =DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
         
        SELECT @An_TotFuture_AMNT = SUM(X.Tot_AMNT)  
      FROM(  
            SELECT MAX(dbo.BATCH_COMMON$SF_GET_AMT_FOR_LOWEST_FREQ(O.Case_IDNO, O.TypeDebt_CODE, dbo.BATCH_COMMON$Sf_GET_LOWEST_FREQ(O.Case_IDNO, O.TypeDebt_CODE))) AS Tot_AMNT  
            FROM OBLE_Y1 O  
            WHERE   
               O.Case_IDNO = @An_Case_IDNO    
              AND SUBSTRING(O.TypeDebt_CODE, @Li_Two_NUMB, @Li_One_NUMB) != @Lc_TypeDebtI_CODE    
              AND CONVERT(DATE,@Ld_Systemdatetime_DTTM) BETWEEN O.BeginObligation_DATE AND O.EndObligation_DATE    
              AND O.EndValidity_DATE = @Ld_High_DATE  
            GROUP BY O.TypeDebt_CODE  
         )  AS X;
                    
END;--End of OBLE_RETRIEVE_S116  
  

GO
