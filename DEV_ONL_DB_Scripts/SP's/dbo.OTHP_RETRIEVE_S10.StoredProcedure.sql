/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S10] (
 @Ac_TypeIncome_CODE CHAR(3),
 @An_MemberMci_IDNO  NUMERIC(10, 0)
 )
AS
 /*
 *     PROCEDURE NAME     : OTHP_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve Other Party Name, Other Party Idno for a Member Idno, Other Party Employment Code, Other Party Type Code, Validity End Date and Employment End Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Lc_SourceIncomeEm_CODE CHAR(2) = 'EM',
          @Lc_TypeOthpE_CODE      CHAR(1) = 'E';

  SELECT OT.OtherParty_IDNO,
         OT.OtherParty_NAME
    FROM EHIS_Y1 EH
         JOIN OTHP_Y1 OT
          ON EH.OthpPartyEmpl_IDNO = OT.OtherParty_IDNO
   WHERE EH.MemberMci_IDNO = @An_MemberMci_IDNO
   AND OT.TypeOthp_CODE = CASE WHEN @Ac_TypeIncome_CODE = @Lc_SourceIncomeEm_CODE
                              THEN @Lc_TypeOthpE_CODE
                          END
     AND OT.EndValidity_DATE = @Ld_High_DATE
     AND EH.EndEmployment_DATE = @Ld_High_DATE
   ORDER BY OT.OtherParty_NAME;
 END; --End of OTHP_RETRIEVE_S10

GO
