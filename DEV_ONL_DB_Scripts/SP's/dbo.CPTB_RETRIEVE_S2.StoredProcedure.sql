/****** Object:  StoredProcedure [dbo].[CPTB_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPTB_RETRIEVE_S2] (
 @An_TransHeader_IDNO          NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE    CHAR(2),
 @Ad_Transaction_DATE          DATE,
 @Ai_Record_NUMB               INT,
 @An_MemberMci_IDNO            NUMERIC(10, 0) OUTPUT,
 @Ac_Last_NAME                 CHAR(20) OUTPUT,
 @Ac_First_NAME                CHAR(16) OUTPUT,
 @Ac_Middle_NAME               CHAR(20) OUTPUT,
 @Ac_Suffix_NAME               CHAR(4) OUTPUT,
 @Ad_Birth_DATE                DATE OUTPUT,
 @An_MemberSsn_NUMB            NUMERIC(9, 0) OUTPUT,
 @Ac_MemberSex_CODE            CHAR(1) OUTPUT,
 @Ac_Race_CODE                 CHAR(1) OUTPUT,
 @Ac_Relationship_CODE         CHAR(1) OUTPUT,
 @Ac_ParticipantStatus_CODE    CHAR(1) OUTPUT,
 @Ac_ChildRelationshipNcp_CODE CHAR(1) OUTPUT,
 @Ac_ParticipantLine1_ADDR     CHAR(25) OUTPUT,
 @Ac_ParticipantLine2_ADDR     CHAR(25) OUTPUT,
 @Ac_ParticipantCity_ADDR      CHAR(18) OUTPUT,
 @Ac_ParticipantState_ADDR     CHAR(2) OUTPUT,
 @Ac_ParticipantZip_ADDR       CHAR(15) OUTPUT,
 @As_Employer_NAME             VARCHAR(60) OUTPUT,
 @Ac_EmployerLine1_ADDR        CHAR(25) OUTPUT,
 @Ac_EmployerLine2_ADDR        CHAR(25) OUTPUT,
 @Ac_EmployerCity_ADDR         CHAR(18) OUTPUT,
 @Ac_EmployerState_ADDR        CHAR(2) OUTPUT,
 @Ac_EmployerZip_ADDR          CHAR(15) OUTPUT,
 @Ac_EinEmployer_ID            CHAR(9) OUTPUT,
 @Ac_ConfirmedAddress_INDC     CHAR(1) OUTPUT,
 @Ad_ConfirmedAddress_DATE     DATE OUTPUT,
 @Ac_ConfirmedEmployer_INDC    CHAR(1) OUTPUT,
 @Ad_ConfirmedEmployer_DATE    DATE OUTPUT,
 @An_WorkPhone_NUMB            NUMERIC(15, 0) OUTPUT,
 @Ac_PlaceOfBirth_NAME         CHAR(25) OUTPUT,
 @Ac_ChildStateResidence_CODE  CHAR(2) OUTPUT,
 @Ac_ChildPaternityStatus_CODE CHAR(1) OUTPUT,
 @An_RowCount_NUMB             NUMERIC(6, 0) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : CPTB_RETRIEVE_S2    
  *     DESCRIPTION       : Retrieve Csenet Participant Block detials for a Transaction Header Idno, Transaction Date, and Other State Fips Code.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SELECT @An_MemberMci_IDNO = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ad_Birth_DATE = NULL,
         @An_MemberSsn_NUMB = NULL,
         @Ac_MemberSex_CODE = NULL,
         @Ac_Race_CODE = NULL,
         @Ac_Relationship_CODE = NULL,
         @Ac_ParticipantStatus_CODE = NULL,
         @Ac_ChildRelationshipNcp_CODE = NULL,
         @Ac_ParticipantLine1_ADDR = NULL,
         @Ac_ParticipantLine2_ADDR = NULL,
         @Ac_ParticipantCity_ADDR = NULL,
         @Ac_ParticipantState_ADDR = NULL,
         @Ac_ParticipantZip_ADDR = NULL,
         @As_Employer_NAME = NULL,
         @Ac_EmployerLine1_ADDR = NULL,
         @Ac_EmployerLine2_ADDR = NULL,
         @Ac_EmployerCity_ADDR = NULL,
         @Ac_EmployerState_ADDR = NULL,
         @Ac_EmployerZip_ADDR = NULL,
         @Ac_EinEmployer_ID = NULL,
         @Ac_ConfirmedAddress_INDC = NULL,
         @Ad_ConfirmedAddress_DATE = NULL,
         @Ac_ConfirmedEmployer_INDC = NULL,
         @Ad_ConfirmedEmployer_DATE = NULL,
         @An_WorkPhone_NUMB = NULL,
         @Ac_PlaceOfBirth_NAME = NULL,
         @Ac_ChildStateResidence_CODE = NULL,
         @Ac_ChildPaternityStatus_CODE = NULL,
         @An_RowCount_NUMB = NULL;

  SELECT @An_MemberMci_IDNO = X.MemberMci_IDNO,
         @Ac_Last_NAME = X.Last_NAME,
         @Ac_First_NAME = X.First_NAME,
         @Ac_Middle_NAME = X.Middle_NAME,
         @Ac_Suffix_NAME = X.Suffix_NAME,
         @Ad_Birth_DATE = X.Birth_DATE,
         @An_MemberSsn_NUMB = X.MemberSsn_NUMB,
         @Ac_MemberSex_CODE = X.MemberSex_CODE,
         @Ac_Race_CODE = X.Race_CODE,
         @Ac_Relationship_CODE = X.Relationship_CODE,
         @Ac_ParticipantStatus_CODE = X.ParticipantStatus_CODE,
         @Ac_ChildRelationshipNcp_CODE = X.ChildRelationshipNcp_CODE,
         @Ac_ParticipantLine1_ADDR = X.ParticipantLine1_ADDR,
         @Ac_ParticipantLine2_ADDR = X.ParticipantLine2_ADDR,
         @Ac_ParticipantCity_ADDR = X.ParticipantCity_ADDR,
         @Ac_ParticipantState_ADDR = X.ParticipantState_ADDR,
         @Ac_ParticipantZip_ADDR = X.ParticipantZip_ADDR,
         @As_Employer_NAME = X.Employer_NAME,
         @Ac_EmployerLine1_ADDR = X.EmployerLine1_ADDR,
         @Ac_EmployerLine2_ADDR = X.EmployerLine2_ADDR,
         @Ac_EmployerCity_ADDR = X.EmployerCity_ADDR,
         @Ac_EmployerState_ADDR = X.EmployerState_ADDR,
         @Ac_EmployerZip_ADDR = X.EmployerZip_ADDR,
         @Ac_EinEmployer_ID = X.EinEmployer_ID,
         @Ac_ConfirmedAddress_INDC = X.ConfirmedAddress_INDC,
         @Ad_ConfirmedAddress_DATE = X.ConfirmedAddress_DATE,
         @Ac_ConfirmedEmployer_INDC = X.ConfirmedEmployer_INDC,
         @Ad_ConfirmedEmployer_DATE = X.ConfirmedEmployer_DATE,
         @An_WorkPhone_NUMB = X.WorkPhone_NUMB,
         @Ac_PlaceOfBirth_NAME = X.PlaceOfBirth_NAME,
         @Ac_ChildStateResidence_CODE = X.ChildStateResidence_CODE,
         @Ac_ChildPaternityStatus_CODE = X.ChildPaternityStatus_CODE,
         @An_RowCount_NUMB = X.row_count
    FROM (SELECT C.Last_NAME,
                 C.First_NAME,
                 C.Middle_NAME,
                 C.Suffix_NAME,
                 C.Birth_DATE,
                 C.MemberSsn_NUMB,
                 C.MemberMci_IDNO,
                 C.MemberSex_CODE,
                 C.Race_CODE,
                 C.Relationship_CODE,
                 C.ParticipantStatus_CODE,
                 C.ChildRelationshipNcp_CODE,
                 C.ParticipantLine1_ADDR,
                 C.ParticipantLine2_ADDR,
                 C.ParticipantCity_ADDR,
                 C.ParticipantState_ADDR,
                 C.ParticipantZip_ADDR,
                 C.Employer_NAME,
                 C.EmployerLine1_ADDR,
                 C.EmployerLine2_ADDR,
                 C.EmployerCity_ADDR,
                 C.EmployerState_ADDR,
                 C.EmployerZip_ADDR,
                 C.EinEmployer_ID,
                 C.ConfirmedAddress_INDC,
                 C.ConfirmedAddress_DATE,
                 C.ConfirmedEmployer_INDC,
                 C.ConfirmedEmployer_DATE,
                 C.WorkPhone_NUMB,
                 C.PlaceOfBirth_NAME,
                 C.ChildStateResidence_CODE,
                 C.ChildPaternityStatus_CODE,
                 ROW_NUMBER() OVER( ORDER BY C.Transaction_DATE) AS Record_NUMB,
                 COUNT(1) OVER() AS row_count
            FROM CPTB_Y1 C
           WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO
             AND C.Transaction_DATE = @Ad_Transaction_DATE
             AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE) AS X
   WHERE X.Record_NUMB = @Ai_Record_NUMB;
 END; --End of CPTB_RETRIEVE_S2    


GO
