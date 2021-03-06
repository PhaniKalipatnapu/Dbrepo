/****** Object:  StoredProcedure [dbo].[CRAS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CRAS_UPDATE_S1]  
(
    
     @An_Office_IDNO         NUMERIC(3),
	 @Ac_TypeRequest_CODE       CHAR(1),
	 @Ac_Role_ID               CHAR(10),
	 @An_TransactionEventSeq_NUMB   NUMERIC(19)         
 )
AS

/*
 *     PROCEDURE NAME    : CRAS_UPDATE_S1
 *     DESCRIPTION       : Update Status Code to Cancel Request, effective Date with Time to Present System date and time, and Worker ID who created/modified this record for an Office, where Status Code is Pending Request, and where Request Type is Reassignment Request for a Role.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
	DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
	        @Ps_ActionCodeCancel_CNST CHAR(1) = 'C', 
            @Ls_No_TEXT CHAR(1) = 'N', 
            @RoleTypeRequest_CODE CHAR(1) = 'R',  
            @OfficeTypeRequest_CODE CHAR(1) = 'O', 
		    @Ld_Current_DATE   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
      UPDATE CRAS_Y1
         SET 
            Status_CODE =@Ps_ActionCodeCancel_CNST, 
            Update_DTTM = @Ld_Current_DATE,
			TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
      WHERE 
		 CRAS_Y1.Office_IDNO = @An_Office_IDNO AND 
         CRAS_Y1.Status_CODE = @Ls_No_TEXT AND 
		 ((CRAS_Y1.TypeRequest_CODE = @RoleTypeRequest_CODE AND CRAS_Y1.Office_IDNO = @An_Office_IDNO  AND CRAS_Y1.Role_ID = @Ac_Role_ID)  
         OR ( CRAS_Y1.TypeRequest_CODE = @OfficeTypeRequest_CODE AND CRAS_Y1.Office_IDNO = @An_Office_IDNO)) AND  
		 CRAS_Y1.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
      
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
END


GO
