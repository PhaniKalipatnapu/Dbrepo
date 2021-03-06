/****** Object:  StoredProcedure [dbo].[PLIC_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_RETRIEVE_S5] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeLicense_CODE         CHAR(5),
 @Ac_LicenseNo_TEXT           CHAR(25),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ad_ExpireLicense_DATE       DATE OUTPUT,
 @Ad_SuspLicense_DATE         DATE OUTPUT,
 @Ac_Status_CODE              CHAR(2) OUTPUT
 )
AS
 /*      
 	*     PROCEDURE NAME    : PLIC_RETRIEVE_S5      
  	*     DESCRIPTION       : Retrieve License Suspended Date, License Expiration Date and Status code for a Member Idno, License Number, License Type Code and Transaction Event Sequence.      
  	*     DEVELOPED BY      : IMP Team
  	*     DEVELOPED ON      : 08-SEP-2011      
  	*     MODIFIED BY       :       
  	*     MODIFIED ON       :       
  	*     VERSION NO        : 1      
 */
 BEGIN
  SELECT @Ad_ExpireLicense_DATE = NULL,
         @Ad_SuspLicense_DATE = NULL,
         @Ac_Status_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ad_ExpireLicense_DATE = a.ExpireLicense_DATE,
         @Ad_SuspLicense_DATE = a.SuspLicense_DATE,
         @Ac_Status_CODE = a.Status_CODE
    FROM PLIC_Y1 a
   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND RTRIM(LTRIM(a.LicenseNo_TEXT)) = @Ac_LicenseNo_TEXT
     AND RTRIM(LTRIM(a.TypeLicense_CODE)) = @Ac_TypeLicense_CODE
     AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of PLIC_RETRIEVE_S5 

GO
