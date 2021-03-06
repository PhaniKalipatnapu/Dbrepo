/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S12] (
 @An_Application_IDNO                 NUMERIC(15, 0),
 @An_MemberMci_IDNO                   NUMERIC(10, 0))
AS
 BEGIN
  DECLARE @Lc_CaseRelationship_CODE		CHAR(1) = 'D',
		  @Lc_CaseRelationshipNcp_CODE	CHAR(1) = 'A',
          @Lc_Other_CODE				CHAR(1) = 'O',
          @Ld_High_DATE					DATE = '12/31/9999',
          @Lc_Yes_INDC					CHAR(1) = 'Y',
          @Lc_No_INDC					CHAR(1) = 'N';

  SELECT COUNT(1) AS CaseMemberEstablishedCount_QNTY,
         (SELECT COUNT(1)
            FROM APCM_Y1 A
           WHERE A.CaseRelationship_CODE = @Lc_CaseRelationship_CODE
             AND A.Application_IDNO = @An_Application_IDNO
             AND A.EndValidity_DATE = @Ld_High_DATE
             AND A.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, MemberMci_IDNO)) AS NoOfChildCount_QNTY,
         (SELECT COUNT(1)
            FROM APDM_Y1 A
           WHERE Application_IDNO = @An_Application_IDNO
             AND EndValidity_DATE = @Ld_High_DATE
             AND PaternityEst_INDC = @Lc_No_INDC
             AND MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, MemberMci_IDNO)) AS ChildNotYetEstablishedCount_QNTY,
	     (SELECT COUNT(1)  
            FROM APDM_Y1 A  
           WHERE Application_IDNO = @An_Application_IDNO  
             AND EndValidity_DATE = @Ld_High_DATE  
             AND PaternityEst_INDC = @Lc_Yes_INDC 
             AND ( EstablishedFather_CODE = @Lc_Other_CODE
             OR EstablishedMother_CODE = @Lc_Other_CODE )
             AND MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, MemberMci_IDNO)) AS ChildOtherEstablishedCount_QNTY
    FROM APCM_Y1 A
         JOIN APDM_Y1 A1
          ON A.Application_IDNO = A1.Application_IDNO
             AND A.MemberMci_IDNO = A1.MemberMci_IDNO
             AND A.CaseRelationship_CODE = @Lc_CaseRelationship_CODE
             AND A1.PaternityEst_INDC = @Lc_Yes_INDC
             AND A.EndValidity_DATE = @Ld_High_DATE
             AND A1.EndValidity_DATE = @Ld_High_DATE
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, A.MemberMci_IDNO)
     AND A1.EstablishedFatherMci_IDNO IN ( SELECT A.MemberMci_IDNO
                                          FROM APCM_Y1 A
                                          WHERE A.Application_IDNO = @An_Application_IDNO
                                           AND A.MemberMci_IDNO = A1.EstablishedFatherMci_IDNO
                                           AND A.EndValidity_DATE = @Ld_High_DATE )
     AND A1.EstablishedMother_CODE IN ( SELECT A.CaseRelationship_CODE
                                         FROM APCM_Y1 A
                                        WHERE A.Application_IDNO = @An_Application_IDNO
                                          AND A.MemberMci_IDNO = A1.EstablishedMotherMci_IDNO
                                          AND A.EndValidity_DATE = @Ld_High_DATE )
 END; 

GO
