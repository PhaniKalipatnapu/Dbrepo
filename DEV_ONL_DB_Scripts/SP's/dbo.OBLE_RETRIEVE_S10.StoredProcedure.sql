/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S10]  
    (
     @An_Case_IDNO		        NUMERIC(6,0),
     @An_OrderSeq_NUMB		    NUMERIC(2,0),
     @An_ObligationSeq_NUMB	    NUMERIC(2,0),
     @An_SupportYearMonth_NUMB	NUMERIC(6,0),
     @Ac_Exists_INDC			CHAR(1) OUTPUT
     )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S10
 *     DESCRIPTION       : Validation Procedure which checks for existance of TANF status
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

          SET @Ac_Exists_INDC = 'N';

      DECLARE @Li_Number112_NUMB         INT = 112,
              @Lc_WelfareTypeTanf_CODE   CHAR(1) = 'A', 
              @Lc_Yes_INDC               CHAR(1) = 'Y',
              @Ld_SupportYearMonth_DATE  DATE    = DATEADD(D,-1,(DATEADD ( M,1,CONVERT(DATE,(CAST(@An_SupportYearMonth_NUMB AS NVARCHAR(6))+'01'))))) ,
			  @Ld_High_DATE				 DATE    = '12/31/9999' ;
			  
				   
        
       SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
         FROM OBLE_Y1 a 
              JOIN 
              MHIS_Y1 b 
           ON b.Case_IDNO = a.Case_IDNO 
          AND b.MemberMci_IDNO = a.MemberMci_IDNO  
              JOIN 
              MHIS_Y1 c
           ON c.CaseWelfare_IDNO = b.CaseWelfare_IDNO
        WHERE a.Case_IDNO = @An_Case_IDNO 
          AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
          AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
          AND b.Start_DATE <= @Ld_SupportYearMonth_DATE 
          AND (CAST(@An_SupportYearMonth_NUMB AS NVARCHAR) BETWEEN CONVERT(CHAR(6),c.Start_DATE,@Li_Number112_NUMB) AND CONVERT(CHAR(6),c.End_DATE,@Li_Number112_NUMB))
          AND a.EndValidity_DATE = @Ld_High_DATE 
          AND b.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE 
          AND c.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE;

END;--End of OBLE_RETRIEVE_S10 


GO
