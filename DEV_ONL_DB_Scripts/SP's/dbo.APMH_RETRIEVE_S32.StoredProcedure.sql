/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S32](
 @An_Application_IDNO NUMERIC(15, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APMH_RETRIEVE_S32
  *     DESCRIPTION       : Gets the record count for the given Application Id where Type of the welfare is not Medicaid, temperory assistant for needy family/Non-temperory assistant for needy family and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_TypeWelfareFoster_CODE CHAR(1) = 'F',
          @Ld_High_DATE              DATE ='12/31/9999',
          @Lc_CaseRelationshipD_CODE CHAR(1) = 'D';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APMH_Y1 A
         JOIN APCM_Y1 A1
          ON (A.MemberMci_IDNO = A1.MemberMci_IDNO)
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.TypeWelfare_CODE NOT IN (@Lc_TypeWelfareFoster_CODE)
     AND A1.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APMH_RETRIEVE_S32

GO
