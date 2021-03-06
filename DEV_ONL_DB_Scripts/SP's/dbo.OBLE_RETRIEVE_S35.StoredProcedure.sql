/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S35]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S35] (  
     @An_Case_IDNO          NUMERIC(6,0),  
     @An_OrderSeq_NUMB      NUMERIC(2,0),  
     @An_MemberMci_IDNO     NUMERIC(10,0),  
     @Ac_TypeDebt_CODE      CHAR(2),       
     @Ac_Fips_CODE          CHAR(7),  
     @Ad_BeginObligation_DATE DATE,
     @Ai_Count_QNTY         INT  OUTPUT  
)  
AS  
  
/*  
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S35  
 *     DESCRIPTION       : This procedure returns the count of obligation exist in the OBLE_Y1 for a case.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 21-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
        SET @Ai_Count_QNTY = NULL;  
  
  DECLARE   
   @Ld_High_DATE DATE = '12/31/9999';  
            
  SELECT @Ai_Count_QNTY = COUNT(1)  
   FROM OBLE_Y1  a  
  WHERE a.Case_IDNO = @An_Case_IDNO   
          AND a.OrderSEQ_NUMB = @An_OrderSeq_NUMB   
          AND a.Fips_CODE = @Ac_Fips_CODE   
          AND a.MemberMci_IDNO = @An_MemberMci_IDNO   
          AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE   
          AND A.BeginObligation_DATE = @Ad_BeginObligation_DATE
          AND a.EndValidity_DATE = @Ld_High_DATE;  
  
  END;--End of OBLE_RETRIEVE_S35  
  
GO
