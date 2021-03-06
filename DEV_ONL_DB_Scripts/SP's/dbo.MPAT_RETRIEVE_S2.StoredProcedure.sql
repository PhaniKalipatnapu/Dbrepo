/****** Object:  StoredProcedure [dbo].[MPAT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MPAT_RETRIEVE_S2] (
 @An_MemberMci_IDNO                  NUMERIC(10, 0),
 @Ac_BirthCertificate_ID             CHAR(20) OUTPUT,
 @Ac_BornOfMarriage_CODE             CHAR(1) OUTPUT,
 @Ad_Conception_DATE                 DATE OUTPUT,
 @Ac_ConceptionCity_NAME             CHAR(28) OUTPUT,
 @An_ConceptionCounty_IDNO           NUMERIC(3) OUTPUT,
 @Ac_ConceptionState_CODE            CHAR(2) OUTPUT,
 @Ac_ConceptionCountry_CODE          CHAR(2) OUTPUT,
 @Ac_EstablishedMother_CODE          CHAR(1) OUTPUT,
 @An_EstablishedMotherMci_IDNO       NUMERIC(10, 0) OUTPUT,
 @Ac_EstablishedMotherLast_NAME      CHAR(20) OUTPUT,
 @Ac_EstablishedMotherFirst_NAME     CHAR(16) OUTPUT,
 @Ac_EstablishedMotherMiddle_NAME    CHAR(20) OUTPUT,
 @Ac_EstablishedMotherSuffix_NAME    CHAR(4) OUTPUT,
 @Ac_EstablishedFather_CODE          CHAR(1) OUTPUT,
 @An_EstablishedFatherMci_IDNO       NUMERIC(10, 0) OUTPUT,
 @Ac_EstablishedFatherLast_NAME      CHAR(20) OUTPUT,
 @Ac_EstablishedFatherFirst_NAME     CHAR(16) OUTPUT,
 @Ac_EstablishedFatherMiddle_NAME    CHAR(20) OUTPUT,
 @Ac_EstablishedFatherSuffix_NAME    CHAR(4) OUTPUT,
 @Ac_DisEstablishedFather_CODE       CHAR(1) OUTPUT,
 @An_DisEstablishedFatherMci_IDNO    NUMERIC(10, 0) OUTPUT,
 @Ac_DisEstablishedFatherLast_NAME   CHAR(20) OUTPUT,
 @Ac_DisEstablishedFatherFirst_NAME  CHAR(16) OUTPUT,
 @Ac_DisEstablishedFatherMiddle_NAME CHAR(20) OUTPUT,
 @Ac_DisEstablishedFatherSuffix_NAME CHAR(4) OUTPUT,
 @Ac_StatusEstablish_CODE            CHAR(1) OUTPUT,
 @Ac_StateEstablish_CODE             CHAR(2) OUTPUT,
 @Ac_FileEstablish_ID                CHAR(10) OUTPUT,
 @Ac_PaternityEst_INDC				 CHAR(1) OUTPUT,
 @Ac_PaternityEst_CODE               CHAR(2) OUTPUT,
 @Ad_PaternityEst_DATE               DATE OUTPUT,
 @Ac_StateDisestablish_CODE          CHAR(2) OUTPUT,
 @Ac_FileDisestablish_ID             CHAR(10) OUTPUT,
 @Ac_MethodDisestablish_CODE         CHAR(3) OUTPUT,
 @Ad_Disestablish_DATE               DATE OUTPUT,
 @As_DescriptionProfile_TEXT         VARCHAR(200) OUTPUT,
 @Ac_QiStatus_CODE                   CHAR(1) OUTPUT,
 @Ac_VapImage_CODE                   CHAR(1) OUTPUT,
 @Ac_WorkerUpdate_ID                 CHAR(30) OUTPUT,
 @Ad_Update_DTTM                     DATETIME2 OUTPUT,
 @An_TransactionEventSeq_NUMB        NUMERIC(19, 0) OUTPUT,
 @Ad_Birth_DATE                      DATE OUTPUT,
 @Ac_BirthCity_NAME                  CHAR(28) OUTPUT,
 @Ac_BirthState_CODE                 CHAR(2) OUTPUT,
 @Ac_BirthCountry_CODE               CHAR(2) OUTPUT,
 @An_CountyBirth_IDNO                NUMERIC(3, 0) OUTPUT,
 @Ac_History_INDC                    CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : MPAT_RETRIEVE_S2    
  *     DESCRIPTION       : Retrieve Member Paternity details from Member Demographics table for Unique Number Assigned by the System to the Member.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SELECT @Ac_BirthCertificate_ID = NULL,
         @Ac_BornOfMarriage_CODE = NULL,
         @Ad_Conception_DATE = NULL,
         @Ac_ConceptionCity_NAME = NULL,
         @An_ConceptionCounty_IDNO = NULL,
         @Ac_ConceptionState_CODE = NULL,
         @Ac_ConceptionCountry_CODE = NULL,
         @Ac_EstablishedMother_CODE = NULL,
         @An_EstablishedMotherMci_IDNO = NULL,
         @Ac_EstablishedMotherLast_NAME = NULL,
         @Ac_EstablishedMotherFirst_NAME = NULL,
         @Ac_EstablishedMotherMiddle_NAME = NULL,
         @Ac_EstablishedMotherSuffix_NAME = NULL,
         @Ac_EstablishedFather_CODE = NULL,
         @An_EstablishedFatherMci_IDNO = NULL,
         @Ac_EstablishedFatherLast_NAME = NULL,
         @Ac_EstablishedFatherFirst_NAME = NULL,
         @Ac_EstablishedFatherMiddle_NAME = NULL,
         @Ac_EstablishedFatherSuffix_NAME = NULL,
         @Ac_DisEstablishedFather_CODE = NULL,
         @An_DisEstablishedFatherMci_IDNO = NULL,
         @Ac_DisEstablishedFatherLast_NAME = NULL,
         @Ac_DisEstablishedFatherFirst_NAME = NULL,
         @Ac_DisEstablishedFatherMiddle_NAME = NULL,
         @Ac_DisEstablishedFatherSuffix_NAME = NULL,
         @Ac_StatusEstablish_CODE = NULL,
         @Ac_StateEstablish_CODE = NULL,
         @Ac_FileEstablish_ID = NULL,
		 @Ac_PaternityEst_INDC = NULL,
         @Ac_PaternityEst_CODE = NULL,
         @Ad_PaternityEst_DATE = NULL,
         @Ac_StateDisestablish_CODE = NULL,
         @Ac_FileDisestablish_ID = NULL,
         @Ac_MethodDisestablish_CODE = NULL,
         @Ad_Disestablish_DATE = NULL,
         @As_DescriptionProfile_TEXT = NULL,
         @Ac_QiStatus_CODE = NULL,
         @Ac_VapImage_CODE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ad_Update_DTTM = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ad_Birth_DATE = NULL,
         @Ac_BirthCity_NAME = NULL,
         @Ac_BirthState_CODE = NULL,
         @Ac_BirthCountry_CODE = NULL,
         @An_CountyBirth_IDNO = NULL,
         @Ac_History_INDC = NULL;

  DECLARE @Lc_Yes_INDC CHAR(1) = 'Y',
          @Lc_No_INDC  CHAR(1) = 'N';

  SELECT @Ac_BirthCertificate_ID = M.BirthCertificate_ID,
         @Ac_BornOfMarriage_CODE = M.BornOfMarriage_CODE,
         @Ad_Conception_DATE = M.Conception_DATE,
         @Ac_ConceptionCity_NAME = M.ConceptionCity_NAME,
         @An_ConceptionCounty_IDNO = M.ConceptionCounty_IDNO,
         @Ac_ConceptionState_CODE = M.ConceptionState_CODE,
         @Ac_ConceptionCountry_CODE = M.ConceptionCountry_CODE,
         @Ac_EstablishedMother_CODE = M.EstablishedMother_CODE,
         @An_EstablishedMotherMci_IDNO = M.EstablishedMotherMci_IDNO,
         @Ac_EstablishedMotherLast_NAME = M.EstablishedMotherLast_NAME,
         @Ac_EstablishedMotherFirst_NAME = M.EstablishedMotherFirst_NAME,
         @Ac_EstablishedMotherMiddle_NAME = M.EstablishedMotherMiddle_NAME,
         @Ac_EstablishedMotherSuffix_NAME = M.EstablishedMotherSuffix_NAME,
         @Ac_EstablishedFather_CODE = M.EstablishedFather_CODE,
         @An_EstablishedFatherMci_IDNO = M.EstablishedFatherMci_IDNO,
         @Ac_EstablishedFatherLast_NAME = M.EstablishedFatherLast_NAME,
         @Ac_EstablishedFatherFirst_NAME = M.EstablishedFatherFirst_NAME,
         @Ac_EstablishedFatherMiddle_NAME = M.EstablishedFatherMiddle_NAME,
         @Ac_EstablishedFatherSuffix_NAME = M.EstablishedFatherSuffix_NAME,
         @Ac_DisEstablishedFather_CODE = M.DisEstablishedFather_CODE,
         @An_DisEstablishedFatherMci_IDNO = M.DisEstablishedFatherMci_IDNO,
         @Ac_DisEstablishedFatherLast_NAME = M.DisEstablishedFatherLast_NAME,
         @Ac_DisEstablishedFatherFirst_NAME = M.DisEstablishedFatherFirst_NAME,
         @Ac_DisEstablishedFatherMiddle_NAME = M.DisEstablishedFatherMiddle_NAME,
         @Ac_DisEstablishedFatherSuffix_NAME = M.DisEstablishedFatherSuffix_NAME,
         @Ac_StatusEstablish_CODE = M.StatusEstablish_CODE,
         @Ac_StateEstablish_CODE = M.StateEstablish_CODE,
         @Ac_FileEstablish_ID = M.FileEstablish_ID,
		 @Ac_PaternityEst_INDC = M.PaternityEst_INDC,
         @Ac_PaternityEst_CODE = M.PaternityEst_CODE,
         @Ad_PaternityEst_DATE = M.PaternityEst_DATE,
         @Ac_StateDisestablish_CODE = M.StateDisestablish_CODE,
         @Ac_FileDisestablish_ID = M.FileDisestablish_ID,
         @Ac_MethodDisestablish_CODE = M.MethodDisestablish_CODE,
         @Ad_Disestablish_DATE = M.Disestablish_DATE,
         @As_DescriptionProfile_TEXT = M.DescriptionProfile_TEXT,
         @Ac_QiStatus_CODE = M.QiStatus_CODE,
         @Ac_VapImage_CODE = M.VapImage_CODE,
         @Ac_WorkerUpdate_ID = M.WorkerUpdate_ID,
         @Ad_Update_DTTM = M.Update_DTTM,
         @An_TransactionEventSeq_NUMB = M.TransactionEventSeq_NUMB,
         @Ad_Birth_DATE = D.Birth_DATE,
         @Ac_BirthCity_NAME = D.BirthCity_NAME,
         @Ac_BirthState_CODE = D.BirthState_CODE,
         @Ac_BirthCountry_CODE = D.BirthCountry_CODE,
         @An_CountyBirth_IDNO = D.CountyBirth_IDNO,
         @Ac_History_INDC = ISNULL ((SELECT TOP 1 @Lc_Yes_INDC
                                       FROM HMPAT_Y1 H
                                      WHERE H.MemberMci_IDNO = @An_MemberMci_IDNO), @Lc_No_INDC)
    FROM MPAT_Y1 M
         JOIN DEMO_Y1 D
          ON M.MemberMci_IDNO = D.MemberMci_IDNO
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; -- END of MPAT_RETRIEVE_S2


GO
