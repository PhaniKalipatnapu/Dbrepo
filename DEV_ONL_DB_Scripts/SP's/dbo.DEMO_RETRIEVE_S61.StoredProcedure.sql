/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S61]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S61]
AS
 /*                                                                                                                                                              
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S61                                                                                                                     
  *     DESCRIPTION       : Retrieves the Member Demographics details along with application Id, Worker, Transaction event sequence where Member Id is 'F9999999'
  *     DEVELOPED BY      : IMP Team                                                                                                                           
  *     DEVELOPED ON      : 23-SEP-2011                                                                                                                          
  *     MODIFIED BY       :                                                                                                                                      
  *     MODIFIED ON       :                                                                                                                                      
  *     VERSION NO        : 1                                                                                                                                    
 */
 BEGIN
  DECLARE @Ln_MemberMciFoster_IDNO NUMERIC(10) = 0000999998;

  SELECT D.Individual_IDNO,
         D.First_NAME,
         D.Last_NAME,
         D.Middle_NAME,
         D.Suffix_NAME,
         D.MotherMaiden_NAME,
         D.MemberSex_CODE,
         D.MemberSsn_NUMB,
         D.Birth_DATE,
         D.Deceased_DATE,
         D.BirthCity_NAME,
         D.BirthCountry_CODE,
         D.BirthState_CODE,
         D.ColorEyes_CODE,
         D.ColorHair_CODE,
         D.Race_CODE,
         D.DescriptionHeight_TEXT,
         D.DescriptionWeightLbs_TEXT,
         D.Divorce_INDC,
         D.AlienRegistn_ID,
         D.Language_CODE,
         D.CellPhone_NUMB,
         D.HomePhone_NUMB,
         D.Contact_EML,
         D.LicenseDriverNo_TEXT,
         D.TypeProblem_CODE,
         D.Graduation_DATE,
         D.MilitaryBranch_CODE,
         D.Disable_INDC
    FROM DEMO_Y1 D
   WHERE D.MemberMci_IDNO = @Ln_MemberMciFoster_IDNO;
 END; --End of DEMO_RETRIEVE_S61


GO
