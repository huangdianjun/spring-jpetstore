<%@ include file="../common/IncludeTop.jsp"%>

<div id="BackLink">
    <a href="${pageContext.request.contextPath}/catalog">Return to
        Main Menu</a>
</div>

<div id="Catalog">

    <h2>${fn:escapeXml(category.name)}</h2>

    <table>
        <tr>
            <th>Product ID</th>
            <th>Name</th>
        </tr>
        <c:forEach var="product" items="${productList}">
            <tr>
                <td><a
                    href="${pageContext.request.contextPath}/catalog/viewProduct?productId=${fn:escapeXml(product.productId)}">${fn:escapeXml(product.productId)}</a></td>
                <td>${fn:escapeXml(product.name)}</td>
            </tr>
        </c:forEach>
    </table>

</div>

<%@ include file="../common/IncludeBottom.jsp"%>


