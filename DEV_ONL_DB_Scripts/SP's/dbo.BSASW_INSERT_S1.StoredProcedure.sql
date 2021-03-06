/****** Object:  StoredProcedure [dbo].[BSASW_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSASW_INSERT_S1]
(
	@Ac_TypeComponent_CODE		CHAR(4),
	@Ad_Request_DATE			DATE,
	@Ac_StatewideSummary_INDC	CHAR(1)
)
AS
/*
 *     PROCEDURE NAME    : BSASW_INSERT_S1
 *     DESCRIPTION       : Insert for statewide records.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 01-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

   DECLARE @Ld_High_DATE			DATE = '12/31/9999';
	
	INSERT INTO BSASW_Y1
                (TypeComponent_CODE, 
                 Request_DATE,
                 StatewideSummary_INDC,   
                 StatusRequest_DATE
                )
         VALUES (@Ac_TypeComponent_CODE,	--TypeComponent_CODE
				 @Ad_Request_DATE,			--Request_DATE
                 @Ac_StatewideSummary_INDC,	--StatewideSummary_INDC
                 @Ld_High_DATE				--StatusRequest_DATE
                );
				
END -- END OF BSASW_INSERT_S1


GO
