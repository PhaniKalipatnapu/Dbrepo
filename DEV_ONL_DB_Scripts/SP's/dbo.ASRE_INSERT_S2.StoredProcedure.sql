/****** Object:  StoredProcedure [dbo].[ASRE_INSERT_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRE_INSERT_S2](
     
     @An_MemberMci_IDNO            NUMERIC(10, 0),
     @Ac_Asset_CODE                CHAR(3),
     @An_AssetSeq_NUMB             NUMERIC(3, 0),
     @Ac_SourceLoc_CODE            CHAR(3),
     @An_TransactionEventSeq_NUMB  NUMERIC(19, 0),
     @Ac_AssetLotNo_TEXT           CHAR(5),
     @Ac_AssetBookNo_TEXT          CHAR(5),
     @Ac_AssetPageNo_TEXT          CHAR(5),
     @As_Line1Asset_ADDR           VARCHAR(50),
     @As_Line2Asset_ADDR           VARCHAR(50),
     @Ac_CityAsset_ADDR            CHAR(28),
     @Ac_StateAsset_ADDR           CHAR(2),
     @Ac_CountryAsset_ADDR         CHAR(2),
     @Ac_ZipAsset_ADDR             CHAR(15),
     @Ad_Purchase_DATE             DATE,
     @An_ValueAsset_AMNT           NUMERIC(11, 2),
     @An_OthpLien_IDNO             NUMERIC(9, 0),
     @Ac_LienInitiated_INDC        CHAR(1),
     @An_Mortgage_AMNT             NUMERIC(11, 2),
     @An_MortgageBalance_AMNT      NUMERIC(11, 2),
     @Ad_Balance_DATE              DATE,
     @Ad_Sold_DATE                 DATE,
     @Ac_Status_CODE               CHAR(1),
     @Ad_Status_DATE               DATE,
     @Ac_CntyFipsAssess_CODE       CHAR(3),
     @Ac_StateAssess_CODE          CHAR(2),
     @Ac_Mortgage_INDC             CHAR(1),
     @Ac_SignedOnWorker_ID         CHAR(30)
     
 )
AS
 /*
  * PROCEDURE NAME    : ASRE_INSERT_S2
  * DESCRIPTION       : Insert Realty Asset details with new Sequence Event Transaction and retrieved Unique number generated for Each Asset into Realty Assets table for Unique number assigned by the System to the Participants.
  * DEVELOPED BY      : IMP Team
  * DEVELOPED ON      : 20-AUG-2011
  * MODIFIED BY       : 
  * MODIFIED ON       : 
  * VERSION NO        : 1
 */
 BEGIN
 
 DECLARE 
 		@Ld_Systemdatetime_DTTM	  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
 		@Ld_High_DATE			  DATE	    = '12/31/9999';
 		
  INSERT ASRE_Y1
         (MemberMci_IDNO,
          Asset_CODE,
          AssetSeq_NUMB,
          AssetLotNo_TEXT,
          SourceLoc_CODE,
          AssetBookNo_TEXT,
          AssetPageNo_TEXT,
          Line1Asset_ADDR,
          Line2Asset_ADDR,
          CityAsset_ADDR,
          StateAsset_ADDR,
          CountryAsset_ADDR,
          ZipAsset_ADDR,
          Purchase_DATE,
          ValueAsset_AMNT,
          OthpLien_IDNO,
          LienInitiated_INDC,
          Mortgage_AMNT,
          MortgageBalance_AMNT,
          Balance_DATE,
          Sold_DATE,
          Status_CODE,
          Status_DATE,
          CntyFipsAssess_CODE,
          StateAssess_CODE,
          Mortgage_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB)
  VALUES ( @An_MemberMci_IDNO,
           @Ac_Asset_CODE,
           @An_AssetSeq_NUMB,
           @Ac_AssetLotNo_TEXT,
           @Ac_SourceLoc_CODE,
           @Ac_AssetBookNo_TEXT,
           @Ac_AssetPageNo_TEXT,
           @As_Line1Asset_ADDR,
           @As_Line2Asset_ADDR,
           @Ac_CityAsset_ADDR,
           @Ac_StateAsset_ADDR,
           @Ac_CountryAsset_ADDR,
           @Ac_ZipAsset_ADDR,
           @Ad_Purchase_DATE,
           @An_ValueAsset_AMNT,
           @An_OthpLien_IDNO,
           @Ac_LienInitiated_INDC,
           @An_Mortgage_AMNT,
           @An_MortgageBalance_AMNT,
           @Ad_Balance_DATE,
           @Ad_Sold_DATE,
           @Ac_Status_CODE,
           @Ad_Status_DATE,
           @Ac_CntyFipsAssess_CODE,
           @Ac_StateAssess_CODE,
           @Ac_Mortgage_INDC,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB);
 END;-- END Of ASRE_INSERT_S2


GO
