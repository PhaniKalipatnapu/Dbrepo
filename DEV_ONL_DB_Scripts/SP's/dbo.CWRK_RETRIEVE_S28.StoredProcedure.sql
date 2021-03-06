/****** Object:  StoredProcedure [dbo].[CWRK_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CWRK_RETRIEVE_S28] (
 @Ac_Worker_ID        CHAR(30),
 @An_Office_IDNO      NUMERIC(3),
 @Ac_Role_ID          CHAR(10),
 @Ac_HighProfile_INDC CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CWRK_RETRIEVE_S28
  *     DESCRIPTION       : Retrieve High Profile Roles for a Case ID & Members Case Relation is CP in Case Member 
  *							and Member ID in Case Member is equal to member ID in Member Demographics and also exists in User Restrictions.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
 */
 BEGIN
  SET @Ac_HighProfile_INDC = 'N';

  DECLARE @Lc_RelationshipCaseCp_CODE CHAR(1) = 'C',
          @Lc_HighProfileYes_INDC     CHAR(1) = 'Y',
          @Ld_Current_DATE            DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE               DATE = '12/31/9999';

  SELECT TOP 1 @Ac_HighProfile_INDC = UR.HighProfile_INDC
    FROM USRT_Y1 UR
         JOIN CMEM_Y1 CM
          ON UR.Case_IDNO = CM.Case_IDNO
             AND UR.MemberMci_IDNO = CM.MemberMci_IDNO
   WHERE UR.Worker_ID = @Ac_Worker_ID
     AND UR.HighProfile_INDC = @Lc_HighProfileYes_INDC
     AND UR.EndValidity_DATE = @Ld_High_DATE
     AND CM.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE
     AND UR.Case_IDNO IN(SELECT CW.Case_IDNO
                           FROM CWRK_Y1 CW
                          WHERE CW.Worker_ID = @Ac_Worker_ID
                            AND CW.Office_IDNO = @An_Office_IDNO
                            AND CW.Role_ID = @Ac_Role_ID
                            AND @Ld_Current_DATE BETWEEN CW.Effective_DATE AND CW.Expire_DATE
                            AND CW.EndValidity_DATE = @Ld_High_DATE);
 END


GO
