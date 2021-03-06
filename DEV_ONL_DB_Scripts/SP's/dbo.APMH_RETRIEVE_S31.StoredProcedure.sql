/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S31](
 @An_Application_IDNO      NUMERIC(15, 0),
 @Ac_CaseRelationship_CODE CHAR(1),
 @Ai_Count_QNTY            INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APMH_RETRIEVE_S31
  *     DESCRIPTION       : Gets the record count for the given Application Id, Member Id where Type of Welfare is temporary assistant for needy family, Member Id not equal to input CP Member Id and end date validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 29-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_TypeWelfareTanf_CODE CHAR(1) = 'A',
          @Ld_High_DATE            DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APMH_Y1 A
         JOIN APCM_Y1 A1
          ON (A.MemberMci_IDNO = A1.MemberMci_IDNO)
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.TypeWelfare_CODE IN (@Lc_TypeWelfareTanf_CODE)
     AND (@Ac_CaseRelationship_CODE IS NOT NULL
          AND A1.CaseRelationship_CODE IN (@Ac_CaseRelationship_CODE)
           OR @Ac_CaseRelationship_CODE IS NULL)
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APMH_RETRIEVE_S31

GO
