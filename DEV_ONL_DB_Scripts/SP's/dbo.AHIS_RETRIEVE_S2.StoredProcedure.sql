/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S2](
 @An_MemberMci_IDNO                   NUMERIC(10, 0),
 @Ac_TypeAddress_CODE                 CHAR(1),
 @An_TransactionEventSeq_NUMB         NUMERIC(19, 0),
 @Ac_Attn_ADDR                        CHAR(40) OUTPUT,
 @As_Line1_ADDR                       VARCHAR(50) OUTPUT,
 @As_Line2_ADDR                       VARCHAR(50) OUTPUT,
 @Ac_City_ADDR                        CHAR(28) OUTPUT,
 @Ac_State_ADDR                       CHAR(2) OUTPUT,
 @Ac_Country_ADDR                     CHAR(2) OUTPUT,
 @Ac_Zip_ADDR                         CHAR(15) OUTPUT,
 @Ac_Normalization_CODE               CHAR(1) OUTPUT,
 @Ad_Begin_DATE                       DATE OUTPUT,
 @Ad_End_DATE                         DATE OUTPUT,
 @Ac_Status_CODE                      CHAR(1) OUTPUT,
 @Ad_Status_DATE                      DATE OUTPUT,
 @Ac_SourceLoc_CODE                   CHAR(3) OUTPUT,
 @Ad_SourceReceived_DATE              DATE OUTPUT,
 @Ac_SourceVerified_CODE              CHAR(3) OUTPUT,
 @As_DescriptionComments_TEXT         VARCHAR(1000) OUTPUT,
 @As_DescriptionServiceDirection_TEXT VARCHAR(1000) OUTPUT,
 @Ad_Update_DTTM                      DATETIME2 OUTPUT,
 @Ac_WorkerUpdate_ID                  CHAR(30) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : AHIS_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Address Details for a Member Idno, Status Code and Transaction Event Sequence number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_DescriptionComments_TEXT = NULL;
  SET @As_DescriptionServiceDirection_TEXT = NULL;

  -- Initalaize variable
  SELECT @Ac_TypeAddress_CODE = NULL,
         @Ac_Status_CODE = NULL,
         @Ad_SourceReceived_DATE = NULL,
         @Ad_Status_DATE = NULL,
         @Ad_Update_DTTM = NULL,
         @Ac_Attn_ADDR = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @Ac_Normalization_CODE = NULL,
         @Ac_SourceLoc_CODE = NULL,
         @Ac_SourceVerified_CODE = NULL,
         @Ad_Begin_DATE = NULL,
         @Ad_End_DATE = NULL,
         @Ac_WorkerUpdate_ID = NULL;

  SELECT @Ac_TypeAddress_CODE = AD.TypeAddress_CODE,
         @Ac_Attn_ADDR = AD.Attn_ADDR,
         @As_Line1_ADDR = AD.Line1_ADDR,
         @As_Line2_ADDR = AD.Line2_ADDR,
         @Ac_City_ADDR = AD.City_ADDR,
         @Ac_State_ADDR = AD.State_ADDR,
         @Ac_Zip_ADDR = AD.Zip_ADDR,
         @Ac_Country_ADDR = AD.Country_ADDR,
         @Ac_Normalization_CODE = AD.Normalization_CODE,
         @Ac_SourceVerified_CODE = AD.SourceVerified_CODE,
         @Ac_Status_CODE = AD.Status_CODE,
         @Ad_Status_DATE = AD.Status_DATE,
         @Ad_Begin_DATE = AD.Begin_DATE,
         @Ad_End_DATE = AD.End_DATE,
         @Ad_SourceReceived_DATE = AD.SourceReceived_DATE,
         @Ac_SourceLoc_CODE = AD.SourceLoc_CODE,
         @As_DescriptionComments_TEXT = AD.DescriptionComments_TEXT,
         @As_DescriptionServiceDirection_TEXT = AD.DescriptionServiceDirection_TEXT,
         @Ac_WorkerUpdate_ID = AD.WorkerUpdate_ID,
         @Ad_Update_DTTM = AD.Update_DTTM
    FROM AHIS_Y1 AD
   WHERE AD.MemberMci_IDNO = @An_MemberMci_IDNO
     AND AD.TypeAddress_CODE = ISNULL(@Ac_TypeAddress_CODE, AD.TypeAddress_CODE)
     AND AD.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END


GO
