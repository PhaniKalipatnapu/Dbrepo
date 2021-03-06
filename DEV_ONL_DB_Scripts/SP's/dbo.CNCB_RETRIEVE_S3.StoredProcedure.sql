/****** Object:  StoredProcedure [dbo].[CNCB_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CNCB_RETRIEVE_S3] (
 @An_TransHeader_IDNO          NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE    CHAR(2),
 @Ad_Transaction_DATE          DATE,
 @An_MemberMci_IDNO            NUMERIC(10, 0) OUTPUT,
 @Ac_Last_NAME                 CHAR(20) OUTPUT,
 @Ac_First_NAME                CHAR(16) OUTPUT,
 @Ac_Middle_NAME               CHAR(20) OUTPUT,
 @Ac_Suffix_NAME               CHAR(4) OUTPUT,
 @An_MemberSsn_NUMB            NUMERIC(9, 0) OUTPUT,
 @Ad_Birth_DATE                DATE OUTPUT,
 @Ac_Race_CODE                 CHAR(1) OUTPUT,
 @Ac_MemberSex_CODE            CHAR(1) OUTPUT,
 @Ac_PlaceOfBirth_NAME         CHAR(25) OUTPUT,
 @Ac_FtHeight_TEXT             CHAR(3) OUTPUT,
 @Ac_InHeight_TEXT             CHAR(2) OUTPUT,
 @Ac_DescriptionWeightLbs_TEXT CHAR(3) OUTPUT,
 @Ac_ColorHair_CODE            CHAR(3) OUTPUT,
 @Ac_ColorEyes_CODE            CHAR(3) OUTPUT,
 @Ac_DistinguishingMarks_TEXT  CHAR(20) OUTPUT,
 @An_Alias1Ssn_NUMB            NUMERIC(9, 0) OUTPUT,
 @An_Alias2Ssn_NUMB            NUMERIC(9, 0) OUTPUT,
 @Ac_PossiblyDangerous_INDC    CHAR(1) OUTPUT,
 @Ac_Maiden_NAME               CHAR(21) OUTPUT,
 @Ac_FatherOrMomMaiden_NAME    CHAR(21) OUTPUT
 )
AS
 /*                                                                                                                                        
  *     PROCEDURE NAME    : CNCB_RETRIEVE_S3                                                                                                
  *     DESCRIPTION       : Retrieve Csenet Ncp Block details for a Transaction Header Idno, Transaction Date, and Other State Fips Code.  
  *     DEVELOPED BY      : IMP Team                                                                                                     
  *     DEVELOPED ON      : 01-SEP-2011                                                                                                    
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
         @An_MemberSsn_NUMB = NULL,
         @Ad_Birth_DATE = NULL,
         @Ac_Race_CODE = NULL,
         @Ac_MemberSex_CODE = NULL,
         @Ac_PlaceOfBirth_NAME = NULL,
         @Ac_FtHeight_TEXT = NULL,
         @Ac_InHeight_TEXT = NULL,
         @Ac_DescriptionWeightLbs_TEXT = NULL,
         @Ac_ColorHair_CODE = NULL,
         @Ac_ColorEyes_CODE = NULL,
         @Ac_DistinguishingMarks_TEXT = NULL,
         @An_Alias1Ssn_NUMB = NULL,
         @An_Alias2Ssn_NUMB = NULL,
         @Ac_PossiblyDangerous_INDC = NULL,
         @Ac_Maiden_NAME = NULL,
         @Ac_FatherOrMomMaiden_NAME = NULL;

  SELECT @An_MemberMci_IDNO = C.MemberMci_IDNO,
         @Ac_Last_NAME = C.Last_NAME,
         @Ac_First_NAME = C.First_NAME,
         @Ac_Middle_NAME = C.Middle_NAME,
         @Ac_Suffix_NAME = C.Suffix_NAME,
         @An_MemberSsn_NUMB = C.MemberSsn_NUMB,
         @Ad_Birth_DATE = C.Birth_DATE,
         @Ac_Race_CODE = C.Race_CODE,
         @Ac_MemberSex_CODE = C.MemberSex_CODE,
         @Ac_PlaceOfBirth_NAME = C.PlaceOfBirth_NAME,
         @Ac_FtHeight_TEXT = C.FtHeight_TEXT,
         @Ac_InHeight_TEXT = C.InHeight_TEXT,
         @Ac_DescriptionWeightLbs_TEXT = C.DescriptionWeightLbs_TEXT,
         @Ac_ColorHair_CODE = C.ColorHair_CODE,
         @Ac_ColorEyes_CODE = C.ColorEyes_CODE,
         @Ac_DistinguishingMarks_TEXT = C.DistinguishingMarks_TEXT,
         @An_Alias1Ssn_NUMB = C.Alias1Ssn_NUMB,
         @An_Alias2Ssn_NUMB = C.Alias2Ssn_NUMB,
         @Ac_PossiblyDangerous_INDC = C.PossiblyDangerous_INDC,
         @Ac_Maiden_NAME = C.Maiden_NAME,
         @Ac_FatherOrMomMaiden_NAME = C.FatherOrMomMaiden_NAME
    FROM CNCB_Y1 C
   WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO
     AND C.Transaction_DATE = @Ad_Transaction_DATE
     AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;
 END; --End of CNCB_RETRIEVE_S3

GO
