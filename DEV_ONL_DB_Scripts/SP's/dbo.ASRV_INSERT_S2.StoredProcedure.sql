/****** Object:  StoredProcedure [dbo].[ASRV_INSERT_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRV_INSERT_S2](
          @An_MemberMci_IDNO            NUMERIC(10, 0),
          @Ac_Asset_CODE                CHAR(3),
          @An_AssetSeq_NUMB             NUMERIC(3, 0),
          @Ac_SourceLoc_CODE            CHAR(3),
          @An_TransactionEventSeq_NUMB  NUMERIC(19, 0),
          @Ac_TitleNo_TEXT              CHAR(15),
          @Ac_DescriptionVin_TEXT       CHAR(20),
          @Ac_DescriptionAutoMake_TEXT  CHAR(15),
          @Ac_DescriptionAutoModel_TEXT CHAR(15),
          @Ac_DescriptionAutoYear_TEXT  CHAR(4),
          @Ac_DescriptionAutoNoLic_TEXT CHAR(10),
          @Ac_StateVehicle_CODE         CHAR(2),
          @Ad_Issued_DATE               DATE,
          @Ad_Expired_DATE              DATE,
          @An_ValueAsset_AMNT           NUMERIC(11, 2),
          @An_OthpLien_IDNO             NUMERIC(9, 0),
          @Ac_StateAssess_CODE          CHAR(2),
          @Ac_CntyFipsAssess_CODE       CHAR(3),
          @An_ValueAssessed_AMNT        NUMERIC(11, 2),
          @Ac_AccountLienNo_TEXT        CHAR(15),
          @An_Lien_AMNT                 NUMERIC(11, 2),
          @Ac_LienInitiated_INDC        CHAR(1),
          @Ac_Status_CODE               CHAR(1),
          @Ad_Status_DATE               DATE, 
          @Ac_SignedOnWorker_ID         CHAR(30)
          
 )
AS
 /*
  *  PROCEDURE NAME    : ASRV_INSERT_S2
  *  DESCRIPTION       : Insert Registered Vehicle details with new Sequence Event Transaction and retrieved Unique number generated for Each Asset into Registered Vehicles table for Unique number assigned by the System to the Participants.
  *  DEVELOPED BY      : IMP Team
  *  DEVELOPED ON      : 20-SEP-2011
  *  MODIFIED BY       : 
  *  MODIFIED ON       : 
  *  VERSION NO        : 1
 */
 BEGIN
 
 DECLARE 
 		@Ld_Systemdatetime_DTTM	  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
 		@Ld_High_DATE			  DATE	    = '12/31/9999';
 		
  INSERT ASRV_Y1
         (MemberMci_IDNO,
          Asset_CODE,
          AssetSeq_NUMB,
          SourceLoc_CODE,
          TitleNo_TEXT,
          DescriptionVin_TEXT,
          DescriptionAutoMake_TEXT,
          DescriptionAutoModel_TEXT,
          DescriptionAutoYear_TEXT,
          DescriptionAutoNoLic_TEXT,
          StateVehicle_CODE,
          Issued_DATE,
          Expired_DATE,
          ValueAsset_AMNT,
          OthpLien_IDNO,
          StateAssess_CODE,
          CntyFipsAssess_CODE,
          ValueAssessed_AMNT,
          AccountLienNo_TEXT,
          Lien_AMNT,
          LienInitiated_INDC,
          Status_CODE,
          Status_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB)
  VALUES ( @An_MemberMci_IDNO,
           @Ac_Asset_CODE,
           @An_AssetSeq_NUMB,
           @Ac_SourceLoc_CODE,
           @Ac_TitleNo_TEXT,
           @Ac_DescriptionVin_TEXT,
           @Ac_DescriptionAutoMake_TEXT,
           @Ac_DescriptionAutoModel_TEXT,
           @Ac_DescriptionAutoYear_TEXT,
           @Ac_DescriptionAutoNoLic_TEXT,
           @Ac_StateVehicle_CODE,
           @Ad_Issued_DATE,
           @Ad_Expired_DATE,
           @An_ValueAsset_AMNT,
           @An_OthpLien_IDNO,
           @Ac_StateAssess_CODE,
           @Ac_CntyFipsAssess_CODE,
           @An_ValueAssessed_AMNT,
           @Ac_AccountLienNo_TEXT,
           @An_Lien_AMNT,
           @Ac_LienInitiated_INDC,
           @Ac_Status_CODE,
           @Ad_Status_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID  ,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB);
 END; -- End Of ASRV_INSERT_S2


GO
