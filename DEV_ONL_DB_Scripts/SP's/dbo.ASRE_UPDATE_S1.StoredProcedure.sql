/****** Object:  StoredProcedure [dbo].[ASRE_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRE_UPDATE_S1]  (
     @An_MemberMci_IDNO               NUMERIC(10, 0),
     @Ac_Asset_CODE                   CHAR(3),
     @An_AssetSeq_NUMB                NUMERIC(3, 0),
     @Ac_AssetLotNo_TEXT              CHAR(5),
     @Ac_SourceLoc_CODE               CHAR(3),
     @Ac_AssetBookNo_TEXT             CHAR(5),
     @Ac_AssetPageNo_TEXT             CHAR(5),
     @As_Line1Asset_ADDR              VARCHAR(50),
     @As_Line2Asset_ADDR              VARCHAR(50),
     @Ac_CityAsset_ADDR               CHAR(28),
     @Ac_StateAsset_ADDR              CHAR(2),
     @Ac_CountryAsset_ADDR            CHAR(2),
     @Ac_ZipAsset_ADDR                CHAR(15),
     @Ad_Purchase_DATE                DATE,
     @An_ValueAsset_AMNT              NUMERIC(11, 2),
     @An_OthpLien_IDNO                NUMERIC(9, 0),
     @Ac_LienInitiated_INDC           CHAR(1),
     @An_Mortgage_AMNT                NUMERIC(11, 2),
     @An_MortgageBalance_AMNT         NUMERIC(11, 2),
     @Ad_Balance_DATE                 DATE,
     @Ad_Sold_DATE                    DATE,
     @Ac_Status_CODE                  CHAR(1),
     @Ad_Status_DATE                  DATE,
     @Ac_CntyFipsAssess_CODE          CHAR(3),
     @Ac_StateAssess_CODE             CHAR(2),
     @Ac_Mortgage_INDC                CHAR(1),
     @Ac_SignedOnWorker_ID            CHAR(30),
     @An_TransactionEventSeqOld_NUMB  NUMERIC(19, 0),
     @An_TransactionEventSeq_NUMB     NUMERIC(19, 0)
    )
   AS
 /*
  *  PROCEDURE NAME    : ASRE_UPDATE_S1
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
 	 		
    UPDATE ASRE_Y1
      SET 
         EndValidity_DATE =@Ld_Systemdatetime_DTTM
           
     OUTPUT  	
 		   @An_MemberMci_IDNO AS MemberMci_IDNO,
 		   @Ac_Asset_CODE AS Asset_CODE,
 		   @An_AssetSeq_NUMB AS AssetSeq_NUMB,
 		   @Ac_AssetLotNo_TEXT AS AssetLotNo_TEXT,
 		   @Ac_SourceLoc_CODE AS SourceLoc_CODE,
 		   @Ac_AssetBookNo_TEXT AS AssetBookNo_TEXT,
 		   @Ac_AssetPageNo_TEXT AS AssetPageNo_TEXT,
 		   @As_Line1Asset_ADDR AS Line1Asset_ADDR,
 		   @As_Line2Asset_ADDR AS  Line2Asset_ADDR,
 		   @Ac_CityAsset_ADDR AS  CityAsset_ADDR,
 		   @Ac_StateAsset_ADDR AS StateAsset_ADDR,
 		   @Ac_CountryAsset_ADDR AS CountryAsset_ADDR,
 		   @Ac_ZipAsset_ADDR AS ZipAsset_ADDR,
 		   @Ad_Purchase_DATE AS Purchase_DATE,
 		   @An_ValueAsset_AMNT AS ValueAsset_AMNT,
 		   @An_OthpLien_IDNO AS OthpLien_IDNO,
 		   @Ac_LienInitiated_INDC AS LienInitiated_INDC,
 		   @An_Mortgage_AMNT AS Mortgage_AMNT,
 		   @An_MortgageBalance_AMNT AS MortgageBalance_AMNT,
 		   @Ad_Balance_DATE AS Balance_DATE,
 		   @Ad_Sold_DATE AS Sold_DATE,
 		   @Ac_Status_CODE AS Status_CODE,
 		   @Ad_Status_DATE AS Status_DATE,
 		   @Ac_CntyFipsAssess_CODE AS CntyFipsAssess_CODE,
 		   @Ac_StateAssess_CODE AS StateAssess_CODE,
 		   @Ac_Mortgage_INDC AS Mortgage_INDC,
 		   @Ld_Systemdatetime_DTTM AS BeginValidity_DATE,
 		   @Ld_High_DATE AS EndValidity_DATE,
 		   @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
 		   @Ld_Systemdatetime_DTTM AS Update_DTTM,
 		   @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
 		INTO ASRE_Y1
 	 WHERE MemberMci_IDNO=@An_MemberMci_IDNO
      AND  TransactionEventSeq_NUMB= @An_TransactionEventSeqOld_NUMB 
      AND  EndValidity_DATE= @Ld_High_DATE;
       	
 		SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
      
   	  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;     
    
END; --END OF ASRE_UPDATE_S1


GO
