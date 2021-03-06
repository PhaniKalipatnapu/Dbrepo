/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S29](
 @An_Application_IDNO NUMERIC(15, 0),
 @An_MemberMci_IDNO   NUMERIC(10, 0)
 )
AS
 /*                                                                                                                                                        
  *     PROCEDURE NAME    : APDM_RETRIEVE_S29                                                                                                               
  *     DESCRIPTION       : Retrieve all Member Demographics details at the time of Application Received for an Application ID and Member ID.                                                                                                                            
  *     DEVELOPED BY      : IMP Team                                                                                                                     
  *     DEVELOPED ON      : 22-AUG-2011                                                                                                                    
  *     MODIFIED BY       :                                                                                                                                
  *     MODIFIED ON       :                                                                                                                                
  *     VERSION NO        : 1                                                                                                                              
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT A.OthpInst_IDNO,
         A.Last_NAME,
         A.First_NAME,
         A.Middle_NAME,
         A.Suffix_NAME,
         A.LastAlias_NAME,
         A.FirstAlias_NAME,
         A.MiddleAlias_NAME,
         A.SuffixAlias_NAME,
         A.MemberSex_CODE,
         A.MemberSsn_NUMB,
         A.Birth_DATE,
         A.Marriage_DATE,
         A.Divorce_DATE,
         A.BirthCity_NAME,
         A.BirthState_CODE,
         A.BirthCountry_CODE,
         A.DescriptionHeight_TEXT,
         A.DescriptionWeightLbs_TEXT,
         A.Race_CODE,
         A.ColorHair_CODE,
         A.ColorEyes_CODE,
         A.Language_CODE,
         A.TypeProblem_CODE,
         A.Deceased_DATE,
         A.LicenseDriverNo_TEXT,
         A.AlienRegistn_ID,
         A.HomePhone_NUMB,
         A.CellPhone_NUMB,
         A.Contact_EML,
         A.MilitaryBranch_CODE,
         A.PaternityEst_INDC,
         A.Divorce_INDC,
         A.ResideCounty_IDNO,
         A.PaternityEst_CODE,
         A.PaternityEst_DATE,
         A.MotherMaiden_NAME,
         A.StateMarriage_CODE,
         A.StateDivorce_CODE,
         A.ConceptionState_CODE,
         A.ConceptionCity_NAME,
         A.EstablishedFather_CODE,
         A.EstablishedMother_CODE,
         A.EstablishedMotherMci_IDNO,
         A.EstablishedFatherMci_IDNO,
         A.EstablishedFatherFirst_NAME,
         A.EstablishedFatherLast_NAME,
         A.EstablishedFatherMiddle_NAME,
         A.EstablishedFatherSuffix_NAME,
         A.EstablishedMotherFirst_NAME,
         A.EstablishedMotherLast_NAME,
         A.EstablishedMotherMiddle_NAME,
         A.EstablishedMotherSuffix_NAME,
         A.IveParty_IDNO,
         A.MilitaryEnd_DATE
    FROM APDM_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APDM_RETRIEVE_S29


GO
