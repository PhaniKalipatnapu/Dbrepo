/****** Object:  StoredProcedure [dbo].[ASRV_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRV_UPDATE_S1]  (

          @An_MemberMci_IDNO               NUMERIC(10, 0),
          @Ac_Asset_CODE                   CHAR(3),
          @An_AssetSeq_NUMB                NUMERIC(3, 0),
          @Ac_SourceLoc_CODE               CHAR(3),
          @Ac_TitleNo_TEXT                 CHAR(15),
          @Ac_DescriptionVin_TEXT          CHAR(20),
          @Ac_DescriptionAutoMake_TEXT     CHAR(15),
          @Ac_DescriptionAutoModel_TEXT    CHAR(15),
          @Ac_DescriptionAutoYear_TEXT     CHAR(4),
          @Ac_DescriptionAutoNoLic_TEXT    CHAR(10),
          @Ac_StateVehicle_CODE            CHAR(2),
          @Ad_Issued_DATE                  DATE,
          @Ad_Expired_DATE                 DATE,
          @An_ValueAsset_AMNT              NUMERIC(11, 2),
          @An_OthpLien_IDNO                NUMERIC(9, 0),
          @Ac_StateAssess_CODE             CHAR(2),
          @Ac_CntyFipsAssess_CODE          CHAR(3),
          @An_ValueAssessed_AMNT           NUMERIC(11, 2),
          @Ac_AccountLienNo_TEXT           CHAR(15),
          @An_Lien_AMNT                    NUMERIC(11, 2),
          @Ac_LienInitiated_INDC           CHAR(1),
          @Ac_Status_CODE                  CHAR(1),
          @Ad_Status_DATE                  DATE, 
          @Ac_SignedOnWorker_ID            CHAR(30),
          @An_TransactionEventSeqOld_NUMB  NUMERIC(19, 0),
          @An_TransactionEventSeq_NUMB     NUMERIC(19, 0)
 )
AS
 /*
  *  PROCEDURE NAME    : ASRV_UPDATE_S1
  *  DESCRIPTION       : UPDATE End validity_DATE to current_DATE for that Membermci_IDNO, Transactioneventseq_numb.
  *  DEVELOPED BY      : IMP Team
  *  DEVELOPED ON      : 20-AUG-2011
  *  MODIFIED BY       : 
  *  MODIFIED ON       : 
  *  VERSION NO        : 1
 */
 BEGIN  
   DECLARE 
 		@Ld_Systemdatetime_DTTM	  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
 		@Ld_High_DATE			  DATE	    = '12/31/9999',
 		@Ln_RowsAffected_NUMB 	  NUMERIC(10);   
   
 	UPDATE ASRV_Y1 
 	 SET
 	    EndValidity_DATE =@Ld_Systemdatetime_DTTM
 	    
 	 OUTPUT
 	      @An_MemberMci_IDNO AS MemberMci_IDNO,
 	      @Ac_Asset_CODE AS Asset_CODE,                  	
 		  @An_AssetSeq_NUMB  AS AssetSeq_NUMB,          
          @Ac_SourceLoc_CODE AS SourceLoc_CODE,          
          @Ac_TitleNo_TEXT   AS TitleNo_TEXT,         
          @Ac_DescriptionVin_TEXT  AS DescriptionVin_TEXT,    
          @Ac_DescriptionAutoMake_TEXT AS DescriptionAutoMake_TEXT,
          @Ac_DescriptionAutoModel_TEXT AS DescriptionAutoModel_TEXT,
          @Ac_DescriptionAutoYear_TEXT  AS DescriptionAutoYear_TEXT,
          @Ac_DescriptionAutoNoLic_TEXT  AS DescriptionAutoNoLic_TEXT,
          @Ac_StateVehicle_CODE  AS StateVehicle_CODE,      
          @Ad_Issued_DATE   AS Issued_DATE,           
          @Ad_Expired_DATE  AS Expired_DATE,           
          @An_ValueAsset_AMNT  AS ValueAsset_AMNT,        
          @An_OthpLien_IDNO   AS OthpLien_IDNO,         
          @Ac_StateAssess_CODE AS StateAssess_CODE,        
          @Ac_CntyFipsAssess_CODE AS CntyFipsAssess_CODE,     
          @An_ValueAssessed_AMNT AS ValueAssessed_AMNT ,     
          @Ac_AccountLienNo_TEXT   AS AccountLienNo_TEXT,    
          @An_Lien_AMNT   AS Lien_AMNT,             
          @Ac_LienInitiated_INDC  AS LienInitiated_INDC,     
          @Ac_Status_CODE  AS Status_CODE,            
          @Ad_Status_DATE  AS Status_DATE,
          @Ld_Systemdatetime_DTTM AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
          @Ld_Systemdatetime_DTTM AS Update_DTTM,
          @An_TransactionEventSeq_NUMB  AS  TransactionEventSeq_NUMB
        INTO ASRV_Y1
      WHERE MemberMci_IDNO=@An_MemberMci_IDNO
       AND  TransactionEventSeq_NUMB= @An_TransactionEventSeqOld_NUMB 
       AND  EndValidity_DATE= @Ld_High_DATE;
       	
 		SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
      
   	  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;     
    
END; --END OF ASRV_UPDATE_S1


GO
