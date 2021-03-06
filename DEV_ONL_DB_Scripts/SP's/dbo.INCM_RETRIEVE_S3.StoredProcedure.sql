/****** Object:  StoredProcedure [dbo].[INCM_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INCM_RETRIEVE_S3]
	(
     	@An_MemberMci_IDNO		 NUMERIC(10,0),
     	@Ac_TypeIncome_CODE      CHAR(3),
     	@An_OtherParty_IDNO		 NUMERIC(9,0),
     	@Ac_Exists_INDC          CHAR(1)   OUTPUT
    )
AS

/*
*     PROCEDURE NAME    : INCM_RETRIEVE_S3
 *     DESCRIPTION       : Retrieve record count for a Member Idno, Source of Income Expense Code, Income Expense Code, Other Party Idno and Validity End Date.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
    BEGIN

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999',
         @Lc_Yes_INDC  CHAR(1)='Y',
         @Lc_No_INDC   CHAR(1)='N';
         
      SET @Ac_Exists_INDC = @Lc_No_INDC;

        SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
 			 FROM INCM_Y1 a
 			WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
 			  AND a.TypeIncome_CODE = @Ac_TypeIncome_CODE
 			  AND (   @An_OtherParty_IDNO IS NULL
 			       OR (    @An_OtherParty_IDNO IS NOT NULL
 			           AND a.OtherParty_IDNO = @An_OtherParty_IDNO
 			          )
 			      )
 			  AND a.EndValidity_DATE = @Ld_High_DATE;


END;  --End of INCM_RETRIEVE_S3

GO
