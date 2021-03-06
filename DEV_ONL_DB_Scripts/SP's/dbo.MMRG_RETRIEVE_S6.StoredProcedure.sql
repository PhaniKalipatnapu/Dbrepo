/****** Object:  StoredProcedure [dbo].[MMRG_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMRG_RETRIEVE_S6] (
	@Ad_Run_DATE         DATE
 )
AS

/*
 *     PROCEDURE NAME    : MMRG_RETRIEVE_S6
 *     DESCRIPTION       : To Retrieve the Status Merged as (M) for Primary and Secondary Member Infromation from MMRG_Y1 Table. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN

   DECLARE @Ld_High_DATE 				DATE = '12/31/9999', 
       	   @Lc_StatusMerged_CODE		CHAR(1) = 'M';

   SELECT MemberMciPrimary_IDNO, 
   		  MemberMciSecondary_IDNO, 
    	  TransactionEventSeq_NUMB
	FROM MMRG_Y1
		WHERE StatusMerge_CODE = @Lc_StatusMerged_CODE 
		  AND BeginValidity_DATE >= @Ad_Run_DATE 
		  AND EndValidity_DATE = @Ld_High_DATE;

END; --END OF MMRG_RETRIEVE_S6

GO
