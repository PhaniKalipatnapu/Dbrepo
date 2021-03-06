/****** Object:  StoredProcedure [dbo].[CRAS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRAS_RETRIEVE_S1] (
 @An_Office_IDNO                 NUMERIC(3),
 @Ac_Role_ID                     CHAR(10),
 @Ac_TypeRequest_CODE            CHAR(1) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : CRAS_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Request Type and Transaction sequence for an Office, Role Idno, and where Status Code is Pending Request.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_TypeRequest_CODE = NULL;
  SET @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Lc_No_TEXT CHAR(1) = 'N',
          @RoleTypeRequest_CODE CHAR(1) = 'R',
          @OfficeTypeRequest_CODE CHAR(1) = 'O';

  SELECT @Ac_TypeRequest_CODE = C.TypeRequest_CODE,
         @An_TransactionEventSeq_NUMB = C.TransactionEventSeq_NUMB
    FROM CRAS_Y1 C
   WHERE C.Office_IDNO = @An_Office_IDNO
     AND ((C.TypeRequest_CODE = @RoleTypeRequest_CODE AND C.Office_IDNO = @An_Office_IDNO  AND C.Role_ID = @Ac_Role_ID)
      OR ( C.TypeRequest_CODE = @OfficeTypeRequest_CODE AND C.Office_IDNO = @An_Office_IDNO))
     AND C.Status_CODE = @Lc_No_TEXT;
 END


GO
