/****** Object:  StoredProcedure [dbo].[APEH_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APEH_RETRIEVE_S3](
 @An_Application_IDNO         NUMERIC(15, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeIncome_CODE          CHAR(2) OUTPUT,
 @Ad_BeginEmployment_DATE     DATE OUTPUT,
 @Ad_EndEmployment_DATE       DATE OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_TypeOccupation_CODE      CHAR(3) OUTPUT,
 @Ac_ContactWork_INDC         CHAR(1) OUTPUT,
 @An_OthpEmpl_IDNO            NUMERIC(9, 0) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : APEH_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieve Unique ID of the Employer, Indicator showing Member be contacted at Work, Income Type of the Member, Employment Begin & End Date, Occupation Type and Unique Sequence Number for an Application ID, Member ID and Member ID  not equal to F9999999.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 29-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ac_TypeIncome_CODE = NULL,
         @Ad_BeginEmployment_DATE = NULL,
         @Ad_EndEmployment_DATE = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_TypeOccupation_CODE = NULL,
         @Ac_ContactWork_INDC = NULL,
         @An_OthpEmpl_IDNO = NULL;

  DECLARE @Ld_High_DATE            DATE = '12/31/9999',
          @Ln_MemberMciFoster_IDNO NUMERIC(10) = 0000999998;

  SELECT @An_OthpEmpl_IDNO = A.OthpEmpl_IDNO,
         @Ac_ContactWork_INDC = A.ContactWork_INDC,
         @Ac_TypeIncome_CODE = A.TypeIncome_CODE,
         @Ad_BeginEmployment_DATE = A.BeginEmployment_DATE,
         @Ad_EndEmployment_DATE = A.EndEmployment_DATE,
         @Ac_TypeOccupation_CODE = A.TypeOccupation_CODE,
         @An_TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
    FROM APEH_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND CAST(A.MEMBERMCI_IDNO AS VARCHAR) != @Ln_MemberMciFoster_IDNO;
 END; -- End Of APEH_RETRIEVE_S3


GO
