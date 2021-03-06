/****** Object:  StoredProcedure [dbo].[APCM_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[APCM_INSERT_S1](  
 @An_Application_IDNO             NUMERIC(15),  
 @An_MemberMci_IDNO               NUMERIC(10),  
 @Ac_CaseRelationship_CODE        CHAR(1),  
 @Ac_CreateMemberMci_CODE         CHAR(1),  
 @Ac_CpRelationshipToChild_CODE   CHAR(3),  
 @Ac_CpRelationshipToNcp_CODE     CHAR(3),  
 @Ac_NcpRelationshipToChild_CODE  CHAR(3),  
 @Ac_DescriptionRelationship_TEXT CHAR(30),  
 @An_OthpAtty_IDNO                NUMERIC(9),  
 @Ac_Applicant_CODE               CHAR(1),  
 @Ac_AttyComplaint_INDC           CHAR(1),  
 @Ad_FamilyViolence_DATE          DATE,  
 @Ac_FamilyViolence_INDC          CHAR(1),  
 @Ac_TypeFamilyViolence_CODE      CHAR(2),  
 @Ac_SignedOnWorker_ID            CHAR(30),  
 @An_TransactionEventSeq_NUMB     NUMERIC(19)  
 )  
AS  
 /*            
  *     PROCEDURE NAME    : APCM_INSERT_S1            
  *     DESCRIPTION       : Inserts the member details for the respective application and the member.            
  *     DEVELOPED BY      : IMP Team            
  *     DEVELOPED ON      : 02-NOV-2011            
  *     MODIFIED BY       :             
  *     MODIFIED ON       :             
  *     VERSION NO        : 1            
 */  
 DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),  
         @Ld_High_DATE           DATE = '12/31/9999';  
  
 BEGIN  
  INSERT APCM_Y1  
         (Application_IDNO,  
          MemberMci_IDNO,  
          CaseRelationship_CODE,  
          CreateMemberMci_CODE,  
          CpRelationshipToChild_CODE,  
          CpRelationshipToNcp_CODE,  
          NcpRelationshipToChild_CODE,  
          DescriptionRelationship_TEXT,  
          BeginValidity_DATE,  
          EndValidity_DATE,  
          Update_DTTM,  
          WorkerUpdate_ID,  
          TransactionEventSeq_NUMB,  
          OthpAtty_IDNO,  
          Applicant_CODE,  
          AttyComplaint_INDC,  
          FamilyViolence_DATE,  
          FamilyViolence_INDC,  
          TypeFamilyViolence_CODE)  
  SELECT   @An_Application_IDNO,  
           @An_MemberMci_IDNO,  
           @Ac_CaseRelationship_CODE,  
           @Ac_CreateMemberMci_CODE,  
           @Ac_CpRelationshipToChild_CODE,  
           @Ac_CpRelationshipToNcp_CODE,  
           @Ac_NcpRelationshipToChild_CODE,  
           @Ac_DescriptionRelationship_TEXT,  
           @Ld_Systemdatetime_DTTM,  
           @Ld_High_DATE,  
           @Ld_Systemdatetime_DTTM,  
           @Ac_SignedOnWorker_ID,  
           @An_TransactionEventSeq_NUMB,  
           @An_OthpAtty_IDNO,  
           @Ac_Applicant_CODE,  
           @Ac_AttyComplaint_INDC,  
           @Ad_FamilyViolence_DATE,  
           @Ac_FamilyViolence_INDC,  
           @Ac_TypeFamilyViolence_CODE 
           WHERE   NOT EXISTS (SELECT 1 FROM APCM_Y1  A WITH (Readuncommitted ) 
          WHERE Application_IDNO=@An_Application_IDNO AND MemberMci_IDNO=@An_MemberMci_IDNO AND TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB AND EndValidity_DATE =@Ld_High_DATE );     
 END; --End of APCM_INSERT_S1  

GO
