/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S126]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S126](  
   @An_Case_IDNO    NUMERIC(6,0),  
   @An_OrderSeq_NUMB   NUMERIC(2,0),  
   @Ac_TypeDebt_CODE   CHAR(2),  
   @Ac_Fips_CODE    CHAR(7),  
   @Ad_BeginObligation_DATE   DATE OUTPUT              
  )  
AS  
/*  
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S126  
 *     DESCRIPTION       : This procedure returns begin obligation date for accrual arrear caluclation.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 17-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
   BEGIN  
   DECLARE  
         @Ld_High_DATE DATE  = '12/31/9999';  
          
   SELECT @Ad_BeginObligation_DATE = ISNULL(MAX(a.BeginObligation_DATE),@Ad_BeginObligation_DATE)  
   FROM OBLE_Y1 a  
   WHERE a.Case_IDNO = @An_Case_IDNO   
   AND   a.OrderSeq_NUMB = @An_OrderSeq_NUMB   
   AND   a.TypeDebt_CODE = @Ac_TypeDebt_CODE   
   AND   a.Fips_CODE = @Ac_Fips_CODE   
   AND   a.BeginObligation_DATE < CONVERT(DATE,CONVERT(CHAR(6),@Ad_BeginObligation_DATE,112)+'01')  
   AND   a.EndValidity_DATE = @Ld_High_DATE;  
                    
END; --END OF OBLE_RETRIEVE_S126  
  
GO
