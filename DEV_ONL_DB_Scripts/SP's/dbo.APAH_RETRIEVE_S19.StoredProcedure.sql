/****** Object:  StoredProcedure [dbo].[APAH_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAH_RETRIEVE_S19](
 @An_Application_IDNO         NUMERIC(15),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_TypeAddress_CODE         CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ad_BeginValidity_DATE       DATE OUTPUT,
 @Ad_EndValidity_DATE         DATE OUTPUT,
 @Ac_Attn_ADDR                CHAR(40) OUTPUT,
 @Ac_City_ADDR                CHAR(28) OUTPUT,
 @Ac_Country_ADDR             CHAR(2) OUTPUT,
 @Ac_County_ADDR              CHAR(3) OUTPUT,
 @As_Line1_ADDR               VARCHAR(50) OUTPUT,
 @As_Line2_ADDR               VARCHAR(50) OUTPUT,
 @Ac_State_ADDR               CHAR(2) OUTPUT,
 @Ac_Zip_ADDR                 CHAR(15) OUTPUT,
 @Ac_Normalization_CODE       CHAR(1) OUTPUT,
 @Ad_AddressAsOf_DATE         DATE OUTPUT,
 @Ac_MemberAddress_CODE       CHAR(1) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @Ad_Update_DTTM              DATETIME2 OUTPUT
 )
AS
 /*    
 *     PROCEDURE NAME    : APAH_RETRIEVE_S19    
  *     DESCRIPTION       : Retrieve Address History details at the time of Application Received for an Application ID, Member ID, Address Type and Unique Sequence Number.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-MAR-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SELECT @Ad_BeginValidity_DATE = NULL,
         @Ad_EndValidity_DATE = NULL,
         @Ad_Update_DTTM = NULL,
         @Ac_Attn_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @Ac_County_ADDR = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @Ac_Normalization_CODE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ad_AddressAsOf_DATE = NULL,
         @Ac_MemberAddress_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_Zero_NUMB SMALLINT = 0;

  SELECT @Ac_Attn_ADDR = AP.Attn_ADDR,
         @Ac_City_ADDR = AP.City_ADDR,
         @Ac_Country_ADDR = AP.Country_ADDR,
         @Ac_County_ADDR = AP.County_ADDR,
         @As_Line1_ADDR = AP.Line1_ADDR,
         @As_Line2_ADDR = AP.Line2_ADDR,
         @Ac_State_ADDR = AP.State_ADDR,
         @Ac_Zip_ADDR = AP.Zip_ADDR,
         @Ac_Normalization_CODE = AP.Normalization_CODE,
         @Ad_BeginValidity_DATE = AP.BeginValidity_DATE,
         @Ad_EndValidity_DATE = AP.EndValidity_DATE,
         @Ac_WorkerUpdate_ID = AP.WorkerUpdate_ID,
         @Ad_Update_DTTM = AP.Update_DTTM,
         @Ad_AddressAsOf_DATE = AP.AddressAsOf_DATE,
         @Ac_MemberAddress_CODE = MemberAddress_CODE
    FROM APAH_Y1 AP
   WHERE AP.Application_IDNO = @An_Application_IDNO
     AND AP.MemberMci_IDNO = @An_MemberMci_IDNO
     AND AP.TypeAddress_CODE = @Ac_TypeAddress_CODE
     AND AP.TransactionEventSeq_NUMB = ISNULL(@An_TransactionEventSeq_NUMB, @Li_Zero_NUMB)
     AND AP.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APAH_RETRIEVE_S19


GO
